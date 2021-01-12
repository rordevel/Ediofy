module Ediofy
  class AnnouncementsController < ApplicationController

    before_action :find_announcement, only: %i[show edit update destroy]
    before_action :find_group, only: %i[new edit create update destroy]

    def show
    end

    def new
      @announcement = current_user.announcements.new(group: @group)
      respond_to { |format| format.js }
    end

    def edit
      respond_to { |format| format.js }
    end

    def create
      @announcement = current_user.announcements.new(announcement_params)
      @announcement.group = @group
      redirect_to ediofy_group_url(@group) if @announcement.save
    end

    def update
      redirect_to ediofy_group_url(@group) if @announcement.update(announcement_params)
    end

    def destroy
      redirect_to ediofy_group_url(@group) if @announcement.delete
    end

    private

    def announcement_params
      params.require(:announcement).permit(:text)
    end

    def find_announcement
      @announcement = Announcement.find(params[:id])
    end

    def find_group
      @group = Group.find(params[:group_id])
    end
  end
end
