if (window.location.hostname.match('localhost') || window.location.hostname.match('192.168')) {
  // don't register service worker on localhost
}
else{
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('service_worker.js')
    .then(function(registration) {
      console.info('registered service worker')
    }).catch(function(err) {
      console.info('failed to register service worker')
      console.info(err)
    })
  }
  else{
    console.info("Sorry, this browser does not support service workers")
  }
}

