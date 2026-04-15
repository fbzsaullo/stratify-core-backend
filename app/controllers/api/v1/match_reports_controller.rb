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
        scores = report.score.to_s.split('-').map(&:to_i)
        team_score = scores[0] || 0
        opp_score = scores[1] || 0

        # Calculations
        error_count = report.feedbacks.where(severity: 'error').count
        warn_count = report.feedbacks.where(severity: 'warning').count
        total_count = report.feedbacks.count
        calc_score = 100 - (error_count * 10) - (warn_count * 3)
        calc_score = [0, calc_score].max

        data = {
          id: report.match_id,
          map: report.map,
          status: report.status,
          score: report.score,
          score_team: team_score,
          score_opponent: opp_score,
          result: team_score >= opp_score ? 'win' : 'loss',
          overall_score: calc_score,
          duration_seconds: report.duration_seconds,
          feedback_count: total_count,
          created_at: report.created_at
        }

        if include_feedbacks
          fbs = report.feedbacks.errors_first.map { |f| serialize_feedback(f) }
          
          # Grouping for frontend
          grouped = fbs.group_by { |f| f[:analyzer] }
          
          # Summary for frontend
          summary = {
            total_errors: total_count,
            critical_errors: error_count,
            warnings: warn_count,
            overall_score: calc_score,
            top_category: report.feedbacks.group(:category).count.sort_by { |_k, v| -v }.first&.first || "aim",
            improvement_areas: report.feedbacks.where(severity: 'error').limit(3).pluck(:category).uniq
          }

          return {
            match: data,
            summary: summary,
            feedbacks_by_analyzer: grouped
          }
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
          confidence_score: feedback.confidence_score,
          created_at: feedback.created_at
        }
      end
    end
  end
end
