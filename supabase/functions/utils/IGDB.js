
export async function getIGDBToken() {
  
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

export async function sendIGDBRequest(request, endpoint, token) {
  
  const response = await fetch(`https://api.igdb.com/v4/${endpoint}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Client-ID": "eo11l1fe0ka6cbupy2foe8yjqloqv8",
      "Authorization": `Bearer ${token}`
    },
    body: request
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  let jsonResponse = await response.json();
  console.log("Response from IGDB:", jsonResponse);
  
  return jsonResponse;
}