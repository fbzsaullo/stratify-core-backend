# frozen_string_literal: true

module Api
  module V1
    class MatchReportsController < ApplicationController
      # GET /api/v1/match_reports
      def index
        player = find_or_create_player
        reports = player.match_reports.recent.limit(20)

        render json: {
          data: reports.map { |r| serialize_report(r) }
        }
      end

      # GET /api/v1/match_reports/:id
      def show
        report = MatchReport.includes(:feedbacks).find_by!(match_id: params[:id])

        render json: {
          data: serialize_report(report, include_feedbacks: true)
        }
      end

      private

      def find_or_create_player
        # MVP: usa steam_id do header ou cria um player demo
        steam_id = request.headers["X-Steam-Id"] || "demo_player_76561198000000001"
        Player.find_or_create_by!(steam_id: steam_id) do |p|
          p.username = request.headers["X-Username"] || "StratifyPlayer"
        end
      end

      def serialize_report(report, include_feedbacks: false)
        data = {
          id: report.match_id,
          map: report.map,
          status: report.status,
          score: report.score,
          duration_seconds: report.duration_seconds,
          feedback_count: report.feedbacks.size,
          created_at: report.created_at
        }

        if include_feedbacks
          data[:feedbacks] = report.feedbacks.errors_first.map { |f| serialize_feedback(f) }
        end

        data
      end

      def serialize_feedback(feedback)
        {
          id: feedback.id,
          analyzer: feedback.analyzer,
          severity: feedback.severity,
          category: feedback.category,
          title: feedback.title,
          description: feedback.description,
          actionable_tip: feedback.actionable_tip,
          confidence_score: feedback.confidence_score
        }
      end
    end
  end
end
