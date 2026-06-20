import { initializeApp, getApps } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDnzl0u7IE-TupVhGv4k09VTgtANoGd7z8",
  authDomain: "kinderlog-70dfd.firebaseapp.com",
  projectId: "kinderlog-70dfd",
  storageBucket: "kinderlog-70dfd.firebasestorage.app",
  messagingSenderId: "732924401958",
  appId: "1:732924401958:web:16bbca2aa59eb8425009e7",
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];
export const db = getFirestore(app);
