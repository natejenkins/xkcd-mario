# from https://www.w3schools.com/howto/howto_css_modals.asp
$(document).ready ->
  modal = document.getElementById('start-modal')
  btn = document.getElementById('settings-icon')
  close = document.getElementById('start-modal-close')
  start_button = document.getElementById('start-button')
  save_button = document.getElementById('save-button')
  load_button = document.getElementById('load-button')
  credits_button = document.getElementById('credits-button')
  volume_on_indicator = document.getElementById('volume-on-indicator')
  volume_off_indicator = document.getElementById('volume-off-indicator')

  credits_button.addEventListener 'click', ->
    modal.style.display = 'none'
    return

  btn.onclick = ->
    world.pause()
    save_button.textContent = "Save"
    modal.style.display = 'block'
    return

  close.onclick = ->
    modal.style.display = 'none'
    world.resume()
    return

  window.addEventListener 'click', (event)->
    if event.target == modal
      world.resume()
      modal.style.display = 'none'
    return

  start_button.onclick = (event) ->
    modal.style.display = 'none'
    world.resume()

  save_button.onclick = (event) ->
    world.save()
    save_button.textContent = 'Game Saved'

  load_button.onclick = (event) ->
    world.load().then(->
      world.resume()
      modal.style.display = 'none'
    )

  volume_on_indicator.onclick = (event) ->
    world.sound_on = false
    Howler.volume(0.0)
    volume_on_indicator.classList.add('hidden')
    volume_off_indicator.classList.remove('hidden')

  volume_off_indicator.onclick = (event) ->
    world.sound_on = true
    Howler.volume(0.1)
    volume_on_indicator.classList.remove('hidden')
    volume_off_indicator.classList.add('hidden')



