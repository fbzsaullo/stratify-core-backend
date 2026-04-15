class LiveCoachChannel < ActionCable::Channel::Base
  def subscribed
    # Para o MVP, todo mundo ouve o mesmo canal "global"
    # Futuramente podemos filtrar por player_id: stream_from "live_coach_#{params[:player_id]}"
    stream_from "live_coach_global"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
