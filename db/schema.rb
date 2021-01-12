# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200224021627) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "key", null: false
    t.text "variables"
    t.text "relation_ids"
    t.text "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_activities_on_key"
    t.index ["user_id", "key"], name: "index_activities_on_user_id_and_key"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "activity_key_point_values", id: :serial, force: :cascade do |t|
    t.string "activity_key", null: false
    t.integer "point_value", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cpd_time", default: 0
    t.string "category"
    t.boolean "enabled"
    t.index ["activity_key"], name: "index_activity_key_point_values_on_activity_key", unique: true
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "street"
    t.string "suburb"
    t.string "state"
    t.string "postcode"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "announcements", id: :serial, force: :cascade do |t|
    t.string "text"
    t.integer "comments_count", default: 0
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.index ["group_id"], name: "index_announcements_on_group_id"
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "answer_translations", force: :cascade do |t|
    t.integer "answer_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body"
    t.index ["answer_id"], name: "index_answer_translations_on_answer_id"
    t.index ["locale"], name: "index_answer_translations_on_locale"
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "media_file_id"
    t.string "attachable_type"
    t.integer "attachable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id"
    t.index ["media_file_id"], name: "index_attachments_on_media_file_id"
  end

  create_table "badge_users", id: :serial, force: :cascade do |t|
    t.integer "badge_id"
    t.integer "user_id"
    t.string "reason_key", null: false
    t.text "reason_relation_ids"
    t.text "reason_variables"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_badge_users_on_badge_id"
    t.index ["user_id"], name: "index_badge_users_on_user_id"
  end

  create_table "badges", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "name", null: false
    t.integer "points"
    t.string "image"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cpd_time", default: 0
  end

  create_table "busy_pipelines", id: :serial, force: :cascade do |t|
    t.string "pipeline_id"
    t.string "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "title", limit: 50, default: ""
    t.text "comment"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.integer "user_id"
    t.string "role", default: "comments"
    t.integer "status", default: 0
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "parent_id"
    t.boolean "private", default: false
    t.integer "replied_to"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.bigint "group_id"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["group_id"], name: "index_comments_on_group_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "conversations", id: :serial, force: :cascade do |t|
    t.text "description"
    t.string "summary"
    t.string "subject"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
    t.boolean "deleted", default: false
    t.integer "comments_count", default: 0
    t.integer "votes_count", default: 0
    t.boolean "private", default: false
    t.string "title"
    t.float "score"
    t.integer "status", default: 0
    t.boolean "group_exclusive", default: false
    t.integer "posted_as_group"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.index ["deleted"], name: "index_conversations_on_deleted"
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "conversations_groups", id: :serial, force: :cascade do |t|
    t.integer "conversation_id"
    t.integer "group_id"
    t.index ["conversation_id"], name: "index_conversations_groups_on_conversation_id"
    t.index ["group_id"], name: "index_conversations_groups_on_group_id"
  end

  create_table "cpd_times", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "activity_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.index ["activity_id"], name: "index_cpd_times_on_activity_id"
    t.index ["user_id"], name: "index_cpd_times_on_user_id"
  end

  create_table "default_placeholders", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "placeholderable_type"
    t.integer "placeholderable_id"
    t.index ["placeholderable_type", "placeholderable_id"], name: "index_my_shorter_name"
  end

  create_table "ediofy_user_exams", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "exam_mode"
    t.boolean "finished", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.index ["user_id"], name: "index_ediofy_user_exams_on_user_id"
  end

  create_table "follow_requests", force: :cascade do |t|
    t.bigint "follower_id"
    t.bigint "followee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followee_id"], name: "index_follow_requests_on_followee_id"
    t.index ["follower_id"], name: "index_follow_requests_on_follower_id"
  end

  create_table "follows", id: :serial, force: :cascade do |t|
    t.string "followable_type", null: false
    t.integer "followable_id", null: false
    t.string "follower_type", null: false
    t.integer "follower_id", null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["followable_id", "followable_type"], name: "fk_followables"
    t.index ["follower_id", "follower_type"], name: "fk_follows"
  end

  create_table "friendships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.string "status"
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "group_invites", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invite_type"
    t.index ["group_id"], name: "index_group_invites_on_group_id"
    t.index ["user_id"], name: "index_group_invites_on_user_id"
  end

  create_table "group_memberships", id: :serial, force: :cascade do |t|
    t.string "member_type"
    t.integer "member_id", null: false
    t.string "group_type"
    t.integer "group_id"
    t.string "group_name"
    t.string "membership_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_name"], name: "index_group_memberships_on_group_name"
    t.index ["group_type", "group_id"], name: "index_group_memberships_on_group_type_and_group_id"
    t.index ["member_type", "member_id"], name: "index_group_memberships_on_member_type_and_member_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "type"
    t.text "description"
    t.boolean "ispublic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "comments_count", default: 0
    t.integer "votes_count", default: 0
    t.integer "view_count", default: 0
    t.string "image"
    t.string "group_url"
    t.text "textsearch_cache"
  end

  create_table "groups_links", id: :serial, force: :cascade do |t|
    t.integer "link_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_groups_links_on_group_id"
    t.index ["link_id"], name: "index_groups_links_on_link_id"
  end

  create_table "groups_media", id: :serial, force: :cascade do |t|
    t.integer "media_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_groups_media_on_group_id"
    t.index ["media_id"], name: "index_groups_media_on_media_id"
  end

  create_table "groups_questions", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_groups_questions_on_group_id"
    t.index ["question_id"], name: "index_groups_questions_on_question_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "imageable_type"
    t.integer "imageable_id"
    t.string "file"
    t.boolean "file_processing", default: false, null: false
    t.string "file_tmp"
    t.text "file_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "s3_file_name"
    t.string "s3_file_url"
    t.integer "position", default: 0
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "url"
    t.string "title"
    t.string "page_image"
    t.string "page_description"
    t.text "description"
    t.integer "view_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.integer "comments_count", default: 0
    t.integer "votes_count", default: 0
    t.boolean "private", default: false
    t.float "score"
    t.integer "status", default: 0
    t.boolean "group_exclusive", default: false
    t.integer "posted_as_group"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.index ["deleted"], name: "index_links_on_deleted"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "media", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.text "description"
    t.integer "reports_count", default: 0, null: false
    t.integer "view_count", default: 0, null: false
    t.integer "question_media_count", default: 0, null: false
    t.integer "cached_votes_up", default: 0, null: false
    t.integer "cached_votes_down", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.string "new_type"
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.integer "comments_count", default: 0
    t.integer "votes_count", default: 0
    t.integer "status", default: 0
    t.boolean "group_exclusive", default: false
    t.integer "posted_as_group"
    t.index ["deleted"], name: "index_media_on_deleted"
    t.index ["user_id"], name: "index_media_on_user_id"
  end

  create_table "media_files", id: :serial, force: :cascade do |t|
    t.integer "media_id"
    t.string "media_type"
    t.string "file"
    t.integer "reports_count", default: 0, null: false
    t.integer "question_media_count", default: 0, null: false
    t.integer "cached_votes_up", default: 0, null: false
    t.integer "cached_votes_down", default: 0, null: false
    t.integer "status", default: 0
    t.boolean "private", default: false, null: false
    t.float "score"
    t.boolean "file_processing"
    t.string "file_tmp"
    t.text "file_info"
    t.string "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "s3_file_url"
    t.string "s3_file_name"
    t.integer "position", default: 0
    t.string "extension"
    t.boolean "processed", default: false
    t.string "job_id"
    t.string "file_path"
    t.index ["media_id"], name: "index_media_files_on_media_id"
  end

  create_table "notification_settings", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.boolean "notify_follows", default: false
    t.boolean "notify_comments", default: false
    t.boolean "notify_likes", default: false
    t.boolean "notify_tags", default: false
    t.boolean "notify_followed_contributor_post", default: false
    t.boolean "email_follows", default: false
    t.boolean "email_comments", default: false
    t.boolean "email_likes", default: false
    t.boolean "email_tags", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notify_group_members_post", default: false
    t.boolean "notify_group_members_playlist_post", default: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "receiver_id"
    t.integer "sender_id"
    t.string "title"
    t.string "image_url"
    t.string "notification_type"
    t.text "links"
    t.string "body"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["receiver_id"], name: "index_notifications_on_receiver_id"
    t.index ["sender_id"], name: "index_notifications_on_sender_id"
  end

  create_table "playlist_contents", id: :serial, force: :cascade do |t|
    t.integer "playlist_id"
    t.integer "position"
    t.string "playable_type"
    t.bigint "playable_id"
    t.index ["playable_type", "playable_id"], name: "index_playlist_contents_on_playable_type_and_playable_id"
    t.index ["playlist_id"], name: "index_playlist_contents_on_playlist_id"
    t.index ["position"], name: "index_playlist_contents_on_position"
  end

  create_table "playlists", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.boolean "archived"
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "default_photo"
    t.index ["group_id"], name: "index_playlists_on_group_id"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "points", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "activity_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_points_on_activity_id"
    t.index ["user_id"], name: "index_points_on_user_id"
  end

  create_table "question_explanations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.string "locale"
    t.text "body"
    t.index ["question_id"], name: "index_question_explanations_on_question_id"
    t.index ["user_id"], name: "index_question_explanations_on_user_id"
  end

  create_table "question_translations", force: :cascade do |t|
    t.integer "question_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body"
    t.text "explanation"
    t.index ["locale"], name: "index_question_translations_on_locale"
    t.index ["question_id"], name: "index_question_translations_on_question_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_source_id"
    t.string "difficulty"
    t.string "question_image"
    t.boolean "active"
    t.boolean "approved"
    t.float "score", default: 0.0
    t.integer "question_media_count", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.text "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.integer "view_count", default: 0
    t.boolean "deleted", default: false
    t.integer "comments_count", default: 0
    t.integer "votes_count", default: 0
    t.string "title"
    t.boolean "group_exclusive", default: false
    t.integer "posted_as_group"
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.index ["approved"], name: "index_questions_on_approved"
    t.index ["status"], name: "index_questions_on_status"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "references", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "url", null: false
    t.integer "referenceable_id"
    t.string "referenceable_type"
    t.index ["referenceable_id"], name: "index_references_on_referenceable_id"
    t.index ["referenceable_type"], name: "index_references_on_referenceable_type"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "reportable_type"
    t.integer "reportable_id"
    t.string "reason"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_id"], name: "index_reports_on_reportable_id"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "selected_answers", id: :serial, force: :cascade do |t|
    t.integer "answer_id"
    t.boolean "not_sure", default: false, null: false
    t.string "answer_order"
    t.string "difficulty"
    t.string "confidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_selected_answers_on_answer_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "tag_choice"
    t.integer "privacy_public", default: 1, null: false
    t.integer "privacy_friends", default: 1, null: false
    t.datetime "question_reset_date"
    t.string "question_reset", default: "exhausted", null: false
    t.boolean "send_updates", default: true
    t.boolean "ghost_mode", default: false
    t.boolean "private", default: false
    t.boolean "is_active", default: true
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "specialties", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_specialties_on_name"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.integer "tag_type", default: 0
    t.string "ancestry"
    t.string "image"
    t.index ["name", "tag_type"], name: "index_tags_on_name_and_tag_type", unique: true
    t.index ["name"], name: "index_tags_on_name"
    t.index ["tag_type"], name: "index_tags_on_tag_type"
  end

  create_table "universities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.text "description"
    t.string "website"
    t.string "country"
    t.integer "users_count", default: 0, null: false
    t.string "badge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "country", "users_count"], name: "index_universities_on_name_and_country_and_users_count"
  end

  create_table "user_collections", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.text "description"
    t.boolean "private", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_collections_on_user_id"
  end

  create_table "user_collections_objects", id: :serial, force: :cascade do |t|
    t.integer "user_collection_id"
    t.integer "objectable_id", null: false
    t.string "objectable_type", null: false
    t.index ["user_collection_id"], name: "index_user_collections_objects_on_user_collection_id"
  end

  create_table "user_exam_questions", id: :serial, force: :cascade do |t|
    t.integer "user_exam_id"
    t.integer "question_id"
    t.integer "position", default: 1, null: false
    t.string "user_exam_type"
    t.integer "selected_answer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_user_exam_questions_on_question_id"
    t.index ["user_exam_id"], name: "index_user_exam_questions_on_user_exam_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.string "hospital"
    t.string "university"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "twitter_uid"
    t.text "twitter_auth"
    t.string "facebook_uid"
    t.text "facebook_auth"
    t.string "google_uid"
    t.text "google_auth"
    t.string "linkedin_uid"
    t.text "linkedin_auth"
    t.string "biography"
    t.string "avatar"
    t.string "locale", default: "en"
    t.string "website"
    t.boolean "ediofy_terms_accepted", default: false, null: false
    t.integer "university_group_id"
    t.boolean "welcome_sent", default: false, null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.string "device_token"
    t.string "device_type"
    t.string "uuid_iphone"
    t.string "location"
    t.string "qualifications"
    t.string "full_name"
    t.integer "title"
    t.string "about"
    t.boolean "profile_completed", default: false
    t.boolean "interests_selected", default: false
    t.boolean "follows_selected", default: false
    t.integer "view_count", default: 0
    t.integer "specialty_id"
    t.string "username"
    t.boolean "ghost_mode", default: false
    t.boolean "private", default: false
    t.integer "comments_count", default: 0
    t.integer "votes_count", default: 0
    t.boolean "is_active", default: true
    t.date "cpd_from"
    t.date "cpd_to"
    t.index ["ediofy_terms_accepted"], name: "index_users_on_ediofy_terms_accepted"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["facebook_uid"], name: "index_users_on_facebook_uid", unique: true
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["ghost_mode"], name: "index_users_on_ghost_mode"
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
    t.index ["is_active"], name: "index_users_on_is_active"
    t.index ["linkedin_uid"], name: "index_users_on_linkedin_uid", unique: true
    t.index ["profile_completed"], name: "index_users_on_profile_completed"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["specialty_id"], name: "index_users_on_specialty_id"
    t.index ["twitter_uid"], name: "index_users_on_twitter_uid", unique: true
    t.index ["university_group_id"], name: "index_users_on_university_group_id"
  end

  create_table "viewed_histories", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "viewable_type"
    t.integer "viewable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_viewed_histories_on_user_id"
    t.index ["viewable_id"], name: "index_viewed_histories_on_viewable_id"
    t.index ["viewable_type", "viewable_id"], name: "index_viewed_histories_on_viewable_type_and_viewable_id"
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.string "votable_type"
    t.integer "votable_id"
    t.string "voter_type"
    t.integer "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
    t.index ["vote_scope"], name: "index_votes_on_vote_scope"
    t.index ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type"
    t.index ["voter_type", "voter_id"], name: "index_votes_on_voter_type_and_voter_id"
  end

  add_foreign_key "attachments", "media_files"
  add_foreign_key "comments", "groups"
  add_foreign_key "conversations", "users"
  add_foreign_key "links", "users"
  add_foreign_key "users", "specialties"
end
