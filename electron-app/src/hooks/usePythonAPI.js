import { useState, useCallback, useEffect } from "react";

/**
 * Hook để gọi Python API từ React
 * Usage: const { call, loading, error } = usePythonAPI();
 */
export const usePythonAPI = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const call = useCallback(async (action, params = {}) => {
    setLoading(true);
    setError(null);
    
    try {
      if (!window.electronAPI) {
        throw new Error("Electron API not available");
      }
      
      const result = await window.electronAPI.callPythonAPI(action, params);
      
      if (!result.success) {
        throw new Error(result.error || "Unknown error");
      }
      
      setLoading(false);
      return result;
    } catch (err) {
      const errorMsg = err.message || String(err);
      setError(errorMsg);
      setLoading(false);
      throw err;
    }
  }, []);

  return { call, loading, error, setError };
};

/**
 * Hook để listen Python messages
 */
export const usePythonMessages = (callback) => {
  useEffect(() => {
    if (window.electronAPI) {
      window.electronAPI.onPythonMessage(callback);
    }
  }, [callback]);
};

/**
 * Hook để check Python backend ready
 */
export const usePythonReady = () => {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (window.electronAPI) {
      window.electronAPI.onPythonReady(() => {
        setReady(true);
      });
    }
  }, []);

  return ready;
};
