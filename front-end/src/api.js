import axios from "axios";

// Remplace par l'URL récupérée via minikube service backend-service --url
const API_URL = "http://127.0.0.1:52145/api/smartphones";

export const getSmartphones = async () => {
  try {
    const response = await axios.get(API_URL);
    return response.data;
  } catch (error) {
    console.error("❌ API Response Error:", error);
    throw error;
  }
};

export const saveSmartphone = async (smartphone) => {
  try {
    const response = await axios.post(API_URL, smartphone);
    return response.data;
  } catch (error) {
    console.error("❌ Error saving smartphone:", error);
    throw error;
  }
};
