if @user.errors.any?
  json.status FAIL_STATUS
  json.errors @user.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.setting do 
  json.(@user.setting, :id, :user_id, :question_reset_date, :question_reset, :send_updates)
  json.privacy_public t("formtastic.labels.setting.privacy_public_#{@user.setting.privacy_public}") +": "+t("formtastic.hints.setting.privacy_public_#{@user.setting.privacy_public}")
  json.privacy_friends t("formtastic.labels.setting.privacy_friends_#{@user.setting.privacy_friends}") +": "+t("formtastic.hints.setting.privacy_friends_#{@user.setting.privacy_friends}")
  json.tags @user.setting.tags
end    
