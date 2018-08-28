// from https://davidwalsh.name/service-worker-claim

// Copyright 2018 David Walsh

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
// AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

var cacheVersion = 1
var cacheName = "xkcd" + cacheVersion

// Install event - cache files (...or not)
// Be sure to call skipWaiting()!
self.addEventListener('install', function(event) {
  event.waitUntil(
  caches.open(cacheName).then(function(cache) {
        return cache.addAll([/* file1.jpg, file2.png, ... */]);
    }).then(function() {
      // `skipWaiting()` forces the waiting ServiceWorker to become the
      // active ServiceWorker, triggering the `onactivate` event.
      // Together with `Clients.claim()` this allows a worker to take effect
      // immediately in the client(s).
      return self.skipWaiting();
    })
  );
});

// Activate event
// Be sure to call self.clients.claim()
self.addEventListener('activate', function(event) {
  // `claim()` sets this worker as the active worker for all clients that
  // match the workers scope and triggers an `oncontrollerchange` event for
  // the clients.
  return self.clients.claim();
});

self.addEventListener('fetch', function(event) {
  var cacheKey
  // Assume all images are static and all other files should be reloaded when the cache version changes
  if(event.request.url.match('.png')){
    cacheKey = event.request.url
  }
  else{
    cacheKey = event.request.url + '.version=' + cacheVersion
  }
  event.respondWith(
    caches.match(cacheKey)
      .then(function(cacheResponse) {
        // Cache hit - return the response from the cached version
        if (cacheResponse) {
          return cacheResponse;
        }
        return fetch(event.request).then(function(serverResponse){
          var clonedServerResponse = serverResponse.clone()
          caches.open(cacheName).then(function(cache){
            cache.put(cacheKey, clonedServerResponse)
          })
          return serverResponse
        })
      }
    )
    .catch(function(error){
      console.warn("Error in service worker:")
      console.warn(error)
    })
  );
});