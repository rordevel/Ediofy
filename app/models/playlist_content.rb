# frozen_string_literal: true

class PlaylistContent < ActiveRecord::Base
  belongs_to :playable, polymorphic: true
  belongs_to :playlist

  acts_as_list scope: [:playlist]

  default_scope { order(position: :asc, id: :asc) }

  before_create :set_position

  private

  def set_position
    self.position = self.playlist.playlist_contents.count + 1
  end
end
