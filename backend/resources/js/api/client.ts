import axios from 'axios';
import { useAuthStore } from '@/store/useAuthStore';

/** Laravel `MOBILE_API_KEY` bilan bir xil (mobil `DioClient` default — .env bo'lmasa ham ishlashi uchun) */
const DEFAULT_MOBILE_API_KEY =
  '585fa4748bf4212bccfca93adfcd555c15983c9b9c6a894a184753079a783e79';

/**
 * Barcha `/api/v1` marshrutlari `ValidateApiKey` orqali himoyalangan — `X-API-Key` majburiy.
 * `VITE_API_KEY` bo'lsa u ishlatiladi; aks holda default (Laravel .env dagi MOBILE_API_KEY bilan mos).
 * Kalitni almashtirish: `admin/.env` da `VITE_API_KEY=...` qo'ying va `npm run build` qayta.
 */
const getApiKey = (): string => {
  return (import.meta.env.VITE_API_KEY as string | undefined) || DEFAULT_MOBILE_API_KEY;
};

// Determine the base URL dynamically
// If VITE_API_URL is set, use it; otherwise use relative path so it always
// matches the host/port the browser is currently on (works with any port).
const getBaseURL = () => {
  if (import.meta.env.VITE_API_URL) return import.meta.env.VITE_API_URL;
  return '/api/v1';
};

const apiKey = getApiKey();

const apiClient = axios.create({
  baseURL: getBaseURL(),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...(apiKey ? { 'X-API-Key': apiKey } : {}),
  },
});

apiClient.interceptors.request.use((config) => {
  if (apiKey) {
    config.headers['X-API-Key'] = apiKey;
  }
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  /** FormData: default `application/json` olib tashlansin — brauzer `multipart/form-data; boundary=...` qo‘yadi */
  if (config.data instanceof FormData) {
    delete (config.headers as Record<string, string>)['Content-Type'];
  }
  return config;
});

// Response interceptor for handling 401 Unauthorized
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
    }
    return Promise.reject(error);
  }
);

export default apiClient;
