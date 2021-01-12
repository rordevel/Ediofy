require 'oembed_provider'

# Anything not mapped, won't show discovery tags
OembedProvider.controller_maps = {
  'ediofy/user/activities' => { model: 'user', id: 'user_id' },
  'ediofy/user/questions' => { model: 'user', id: 'user_id' },
  'ediofy/user/media' => { model: 'user', id: 'user_id' },
  'ediofy/user/folders' => { model: 'user', id: 'user_id' },
  'ediofy/user/badges' => { model: 'user', id: 'user_id' },
  'ediofy/user/friends' => { model: 'user', id: 'user_id' },
  'ediofy/user/points' => { model: 'user', id: 'user_id' },
  'ediofy/media' => { model: 'Media', id: 'id' }
}