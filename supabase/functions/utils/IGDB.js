function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function getIGDBToken() {
  
    const auth_response = await fetch("https://id.twitch.tv/oauth2/token?client_id=eo11l1fe0ka6cbupy2foe8yjqloqv8&client_secret=x9pgfvyp8bo5xw0qh56t02l2pjoena&grant_type=client_credentials", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      }
    });

    if (!auth_response.ok) {
      throw new Error(`HTTP error! status: ${auth_response.status}`);
    }

    const auth_data = await auth_response.json();
    console.log("Authentication successful:", auth_data);

    var token = auth_data.access_token;
    return token;
}

async function sendIGDBRequest(request, endpoint, token) {
  await sleep(250);
  
  const response = await fetch(`https://api.igdb.com/v4/${endpoint}`, {
    method: "POST",
    headers: {
      "Client-ID": "eo11l1fe0ka6cbupy2foe8yjqloqv8",
      "Authorization": `Bearer ${token}`,
      "Accept": "application/json",
      "Content-Type": "text/plain"
    },
    body: request
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`HTTP error! status: ${response.status}, body: ${errText}`);
  }

  const jsonResponse = await response.json();
  console.log("Response from IGDB:", jsonResponse);

  return jsonResponse;
}


export {sendIGDBRequest, getIGDBToken}