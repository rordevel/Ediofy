if @user.errors.any?
  json.status FAIL_STATUS
  json.errors @user.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.user @user, :id, :email, :first_name, :last_name, :full_name, :biography, :website, :hospital, :university_group_id, :avatar_choice, :avatar
