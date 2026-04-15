# frozen_string_literal: true

# FeedbackIngestionWorker
#
# Consome o stream Redis `stratify:feedback` e persiste cada
# FeedbackGenerated event como um registro Feedback no PostgreSQL.
#
# Rodado como um loop contínuo via `bin/feedback_consumer`.
class FeedbackIngestionWorker
  FEEDBACK_STREAM = "stratify:feedback"
  GROUP_NAME      = "core-backend-ingestor"
  CONSUMER_NAME   = "core-backend-#{Process.pid}"
  BATCH_SIZE      = 10
  BLOCK_MS        = 5_000

  def initialize
    @redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    setup_consumer_group
  end

  def run!
    Rails.logger.info("[FeedbackIngestionWorker] Starting consumer on #{FEEDBACK_STREAM}")

    loop do
      results = @redis.xreadgroup(
        GROUP_NAME, CONSUMER_NAME,
        FEEDBACK_STREAM, ">",
        count: BATCH_SIZE,
        block: BLOCK_MS
      )

      next if results.nil? || results.empty?

      results.each do |_stream, messages|
        messages.each do |msg_id, fields|
          process_message(msg_id, fields)
        end
      end
    end
  rescue Interrupt
    Rails.logger.info("[FeedbackIngestionWorker] Stopped.")
  end

  private

  def setup_consumer_group
    @redis.xgroup(:create, FEEDBACK_STREAM, GROUP_NAME, "$", mkstream: true)
  rescue Redis::CommandError => e
    raise unless e.message.include?("BUSYGROUP")
    # Group already exists — OK
  end

  def process_message(msg_id, fields)
    event = JSON.parse(fields["data"])
    ingest_feedback(event)
    @redis.xack(FEEDBACK_STREAM, GROUP_NAME, msg_id)
  rescue JSON::ParserError => e
    Rails.logger.error("[FeedbackIngestionWorker] JSON parse error: #{e.message}")
    @redis.xack(FEEDBACK_STREAM, GROUP_NAME, msg_id)
  rescue => e
    Rails.logger.error("[FeedbackIngestionWorker] Error processing #{msg_id}: #{e.message}")
    # Em erro de DB, não faz ACK para reprocessar depois
  end

  def ingest_feedback(event)
    payload = event.dig("payload") || {}
    match_id = event["match_id"]

    return unless match_id.present?

    match_report = MatchReport.find_or_create_by!(match_id: match_id) do |mr|
      # Player demo para MVP sem auth — substituir por lookup real depois
      player = Player.find_or_create_by!(steam_id: event["player_id"] || "unknown") do |p|
        p.username = "Unknown Player"
      end
      mr.player = player
      mr.map    = payload.dig("context", "map") || "unknown"
      mr.status = :analyzing
    end

    severity_map = { "info" => 0, "warning" => 1, "error" => 2, "success" => 3 }

    fb = Feedback.create!(
      match_report:     match_report,
      analyzer:         payload["analyzer"] || "unknown",
      severity:         severity_map[payload["severity"]] || 1,
      category:         payload["category"] || "general",
      title:            payload["title"] || "Feedback",
      description:      payload["description"],
      actionable_tip:   payload["actionable_tip"],
      confidence_score: payload["confidence_score"] || 0.0,
      raw_payload:      payload
    )

    # Broadcast Live Coach Tip
    ActionCable.server.broadcast("live_coach_global", {
      id: fb.id,
      analyzer: fb.analyzer,
      severity: payload["severity"] || "warning",
      category: fb.category,
      title: fb.title,
      description: fb.description,
      actionable_tip: fb.actionable_tip,
      confidence_score: fb.confidence_score
    })

    Rails.logger.info("[FeedbackIngestionWorker] Ingested & Broadcasted: #{fb.title}")
  end
end
