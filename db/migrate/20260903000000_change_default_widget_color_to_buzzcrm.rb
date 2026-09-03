class ChangeDefaultWidgetColorToBuzzcrm < ActiveRecord::Migration[7.1]
  def up
    change_column_default :channel_web_widgets, :widget_color, from: '#1f93ff', to: '#0891B2'
  end

  def down
    change_column_default :channel_web_widgets, :widget_color, from: '#0891B2', to: '#1f93ff'
  end
end
