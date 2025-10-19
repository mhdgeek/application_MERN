// front-end/src/api.js
import axios from "axios";

// Remplace par l'IP de ton cluster et le port NodePort
const API_URL = "http://localhost:30080/api/smartphones";

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
