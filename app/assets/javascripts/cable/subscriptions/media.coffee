App.cable.subscriptions.create { 
  channel: "MediaChannel", 
  room: "Best Room" 
},
connected: ->
  console.log 'connected'