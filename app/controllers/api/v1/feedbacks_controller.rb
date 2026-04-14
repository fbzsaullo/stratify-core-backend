# frozen_string_literal: true

module Api
  module V1
    class FeedbacksController < ApplicationController
      # GET /api/v1/match_reports/:match_report_id/feedbacks
      def index
        report = MatchReport.find_by!(match_id: params[:match_report_id])
        feedbacks = report.feedbacks.errors_first

        feedbacks = feedbacks.by_severity(params[:severity]) if params[:severity].present?

        render json: {
          data: feedbacks.map { |f| serialize(f) },
          meta: {
            total: feedbacks.count,
            match_id: report.match_id
          }
        }
      end

      private

      def serialize(feedback)
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
