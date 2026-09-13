const button = document.getElementById("statusButton");
const status = document.getElementById("status");
const hostnameEl = document.getElementById("hostname");

button.addEventListener("click", () => {
    status.textContent = "Application is running!";
    status.style.color = "#107c10";

    button.disabled = true;
    button.textContent = "Running ✓";
});

// Show which pod served the request (nice AKS demo touch)
fetch("/healthz")
    .then(() => {
        hostnameEl.textContent = "Served by: " + window.location.host;
    })
    .catch(() => {
        hostnameEl.textContent = "Served by: " + window.location.host;
    });