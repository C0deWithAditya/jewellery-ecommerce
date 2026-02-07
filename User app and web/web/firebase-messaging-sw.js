importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBCtDfdfPqxXDO6rDNlmQC1VJSHOtuyo3w",
    authDomain: "gem-b5006.firebaseapp.com",
    projectId: "gem-b5006",
    storageBucket: "gem-b5006.firebasestorage.app",
    messagingSenderId: "384321080318",
    appId: "1:384321080318:web:9cf2ec90f41dfb8a2c0eaf",
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});