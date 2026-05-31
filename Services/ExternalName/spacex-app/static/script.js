document.getElementById('fetch-data').addEventListener('click', async () => {
    const missionNameElement = document.getElementById('mission-name');
    const launchDateElement = document.getElementById('launch-date');
    const rocketIdElement = document.getElementById('rocket-id');
    const detailsElement = document.getElementById('details');

    try {
        const response = await fetch('/fetch');
        if (response.ok) {
            const data = await response.json();
            missionNameElement.textContent = data.mission_name || "N/A";
            launchDateElement.textContent = data.launch_date || "N/A";
            rocketIdElement.textContent = data.rocket_id || "N/A";
            detailsElement.textContent = data.details || "N/A";
        } else {
            missionNameElement.textContent = "Error";
            launchDateElement.textContent = "Error";
            rocketIdElement.textContent = "Error";
            detailsElement.textContent = "Error";
        }
    } catch (error) {
        missionNameElement.textContent = "Error";
        launchDateElement.textContent = "Error";
        rocketIdElement.textContent = "Error";
        detailsElement.textContent = error.message;
    }
});