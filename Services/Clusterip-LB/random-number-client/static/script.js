document.getElementById('fetch-data').addEventListener('click', async () => {
    const responseElement = document.getElementById('response');
    try {
        const response = await fetch('/fetch');
        if (response.ok) {
            const data = await response.json();
            responseElement.textContent = `Response: ${data.message || data.error}`;
        } else {
            responseElement.textContent = `Error: ${response.statusText}`;
        }
    } catch (error) {
        responseElement.textContent = `Error: ${error.message}`;
    }
});