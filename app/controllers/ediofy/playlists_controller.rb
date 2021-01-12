# frozen_string_literal: true
module Ediofy
  class PlaylistsController < ApplicationController
    before_action :find_playlist, only: %i[show edit copy remove_content patch set_photo duplicate add update destroy]
    before_action :find_group, only: %i[new create copy destroy]

    def show
      @image = Image.last
      if params[:type].present?
        @playlist_content = select_group_content_by_type @group_content, params[:type]
        @playlist_top_content = select_group_content_by_type @group_top_content, params[:type]
      end

      if params[:sort_by].present?
        @playlist_content = sort_content @group_content, params[:type]
        @playlist_top_content = sort_content @group_top_content, params[:type]
      end
    end

    def new
      respond_to { |format| format.js }
    end

    def edit
      respond_to { |format| format.js }
    end

    def duplicate
      respond_to { |format| format.js }
    end

    def copy
      @playlist = current_user.playlists.new(playlist_params)
      if params[:playlist][:group_id].present? 
          @playlist.group = Group.find(params[:playlist][:group_id]) 
      else
         @playlist.group = @group
      end
      if params['content_id'].present?
        @playlist.instance_eval(params['content_type'].downcase + 's') << params['content_type'].capitalize.constantize.find(params['content_id'])
      end

      @original = Playlist.find(params["id"])
      @playlist.links = @original.links
      @playlist.media = @original.media
      @playlist.conversations = @original.conversations
      @playlist.questions = @original.questions

      @playlist.save
      render :show
    end

    def create
      @playlist = current_user.playlists.new(playlist_params)
      @playlist.group = @group
         
     if params['content_id'].present?
        nameOfContentClass = params['content_type']
        objToAdd = class_eval(nameOfContentClass).find(params['content_id'])
        @playlist.instance_eval(nameOfContentClass.pluralize.downcase) << objToAdd
     end
     
      @playlist.save
      render :show
    end

    def update

      #we are only reordering contents
      if params[:content].present?
      pcs =  PlaylistContent.where(playlist_id: @playlist.id)

      pcs.each_with_index do |pc, index|
        pc.position = params[:content][index].to_i
        pc.save
      end


        respond_to do |format|
            format.js
        end

      else
        if @playlist.update_attributes(playlist_params)
          flash[:success] = 'paylist updated'
          render :show
        else
          render :show
        end
      end
    end

    def destroy
      @playlist.group = @group
      redirect_to ediofy_group_path(@group) if @playlist.delete
    end

    def remove_content
      content = Object.const_get(params[:klass]).find(params[:content_id])

      klass = params[:klass].pluralize.downcase
      @playlist.send(klass).delete content

      respond_to do |format|
        format.html { redirect_to ediofy_playlist_url(@playlist) }
      end
    end

    def set_photo
      @playlist.update_attribute(:default_photo, params[:url])
      redirect_back fallback_location: ediofy_root_url
    end

    private

    def playlist_params
      params.require(:playlist).permit(:title, :description, :archived, :group_id)
    end

    def find_playlist
      @playlist = Playlist.find(params[:id])
    end

    def find_group
      @group = if @playlist.nil? #creating a new playlist
                 Group.find(params[:playlist][:group_id])
               else
                 @playlist.group
               end
    end
  end
end
