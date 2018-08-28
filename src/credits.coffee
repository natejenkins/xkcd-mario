# from https://www.w3schools.com/howto/howto_css_modals.asp
$(document).ready ->
  modal = document.getElementById('credits-modal')
  close = document.getElementById('credits-modal-close')
  credits_button = document.getElementById('credits-button')

  credits_button.addEventListener 'click', ->
    world.pause()
    modal.style.display = 'block'
    return

  close.onclick = ->
    world.resume()
    modal.style.display = 'none'
    return

  # window.onclick = (event) ->
  #   if event.target == modal
  #     world.resume()
  #     modal.style.display = 'none'
  #   return

  window.addEventListener 'click', (event)->
    if event.target == modal
      world.resume()
      modal.style.display = 'none'
    return