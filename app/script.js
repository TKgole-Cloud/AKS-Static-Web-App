const button = document.getElementById("statusButton");
const status = document.getElementById("status");

button.addEventListener("click", () => {
    status.textContent = "Application is running!";
});