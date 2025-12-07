import React, { useState, useCallback } from "react";
import { usePythonAPI, usePythonReady } from "../hooks/usePythonAPI";

export default function EndUserDashboard() {
  const [activeTool, setActiveTool] = useState("keygen");
  const [output, setOutput] = useState("");
  const { call, loading, error } = usePythonAPI();
  const pythonReady = usePythonReady();

  // Form states
  const [mnemonic, setMnemonic] = useState("");
  const [walletPath, setWalletPath] = useState("");
  const [message, setMessage] = useState("");
  const [signature, setSignature] = useState("");
  const [pubkey, setPubkey] = useState("");
  const [address, setAddress] = useState("");

  const addOutput = (text) => {
    setOutput((prev) => prev + text + "\n");
  };

  const handleGenerateKeypair = useCallback(async () => {
    try {
      addOutput("Generating keypair...");
      const result = await call("generate_keypair", {
        mnemonic: mnemonic || undefined,
        wallet_path: walletPath || undefined
      });
      addOutput("✓ Keypair generated successfully!");
      addOutput(JSON.stringify(result.data, null, 2));
    } catch (err) {
      addOutput(`✗ Error: ${err.message}`);
    }
  }, [call, mnemonic, walletPath]);

  const handleSignMessage = useCallback(async () => {
    try {
      addOutput("Signing message...");
      const result = await call("sign_message", {
        message: message,
        skey_path: ""
      });
      addOutput("✓ Message signed!");
      setSignature(result.signature);
      addOutput(`Signature: ${result.signature}`);
    } catch (err) {
      addOutput(`✗ Error: ${err.message}`);
    }
  }, [call, message]);

  const handleVerifySignature = useCallback(async () => {
    try {
      addOutput("Verifying signature...");
      const result = await call("verify_signature", {
        message: message,
        signature: signature,
        pubkey: pubkey
      });
      addOutput(`✓ Signature is ${result.valid ? "VALID" : "INVALID"}`);
    } catch (err) {
      addOutput(`✗ Error: ${err.message}`);
    }
  }, [call, message, signature, pubkey]);

  const handleGetBalance = useCallback(async () => {
    try {
      addOutput("Fetching balance...");
      const result = await call("get_balance", {
        address: address
      });
      addOutput("✓ Balance retrieved!");
      addOutput(JSON.stringify(result, null, 2));
    } catch (err) {
      addOutput(`✗ Error: ${err.message}`);
    }
  }, [call, address]);

  const handleExportWallet = useCallback(async () => {
    try {
      addOutput("Exporting wallet...");
      const result = await call("export_wallet", {
        wallet_path: walletPath || undefined
      });
      addOutput("✓ Wallet exported!");
      addOutput(JSON.stringify(result, null, 2));
    } catch (err) {
      addOutput(`✗ Error: ${err.message}`);
    }
  }, [call, walletPath]);

  const handleCleanupKeys = useCallback(async () => {
    if (!window.confirm("Are you sure? This will delete ALL keys and wallets!")) return;
    try {
      addOutput("Cleaning up keys...");
      const result = await call("cleanup_keys", {
        wallet_path: walletPath || undefined
      });
      addOutput("✓ " + result.message);
    } catch (err) {
      addOutput(`✗ Error: ${err.message}`);
    }
  }, [call, walletPath]);

  const tools = [
    {
      key: "keygen",
      icon: "🔑",
      label: "Generate Keypair",
      render: () => (
        <section className="space-y-4">
          <h2 className="text-xl font-bold text-blue-400">🔑 Generate/Restore Keypair</h2>
          <div>
            <label className="block text-gray-300 mb-2">BIP39 Mnemonic (12/15/24 words)</label>
            <textarea
              value={mnemonic}
              onChange={(e) => setMnemonic(e.target.value)}
              className="w-full p-3 rounded bg-gray-800 text-gray-100 border border-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows={3}
              placeholder="Enter your mnemonic or leave empty to generate new"
            />
          </div>
          <div className="flex gap-2 items-center">
            <label className="block text-gray-300">Wallet Path</label>
            <input
              type="text"
              value={walletPath}
              onChange={(e) => setWalletPath(e.target.value)}
              className="flex-1 p-2 rounded bg-gray-800 text-gray-100 border border-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Select folder to save wallet"
            />
            <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Browse</button>
          </div>
          <button
            onClick={handleGenerateKeypair}
            disabled={loading}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-bold shadow"
          >
            {loading ? "Generating..." : "Generate Addresses"}
          </button>
        </section>
      )
    },
    {
      key: "sign-offline",
      icon: "✍️",
      label: "Sign (Offline)",
      render: () => (
        <section className="space-y-4">
          <h2 className="text-xl font-bold text-blue-400">✍️ Sign Message (Offline)</h2>
          <div>
            <label className="block text-gray-300 mb-2">Message to Sign</label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="w-full p-3 rounded bg-gray-800 text-gray-100 border border-gray-700"
              rows={2}
              placeholder="Enter message to sign"
            />
          </div>
          <div>
            <label className="block text-gray-300 mb-2">Private Key (.skey file)</label>
            <input type="file" accept=".skey" className="block w-full text-gray-100" />
          </div>
          <button
            onClick={handleSignMessage}
            disabled={loading || !message}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-bold shadow"
          >
            {loading ? "Signing..." : "Sign Message"}
          </button>
        </section>
      )
    },
    {
      key: "verify",
      icon: "✓",
      label: "Verify Signature",
      render: () => (
        <section className="space-y-4">
          <h2 className="text-xl font-bold text-blue-400">✓ Verify Signature</h2>
          <div>
            <label className="block text-gray-300 mb-2">Message</label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="w-full p-3 rounded bg-gray-800 text-gray-100 border border-gray-700"
              rows={2}
              placeholder="Original message"
            />
          </div>
          <div>
            <label className="block text-gray-300 mb-2">Signature</label>
            <textarea
              value={signature}
              onChange={(e) => setSignature(e.target.value)}
              className="w-full p-3 rounded bg-gray-800 text-gray-100 border border-gray-700"
              rows={2}
              placeholder="Signature to verify"
            />
          </div>
          <div>
            <label className="block text-gray-300 mb-2">Public Key</label>
            <input
              type="text"
              value={pubkey}
              onChange={(e) => setPubkey(e.target.value)}
              className="w-full p-2 rounded bg-gray-800 text-gray-100 border border-gray-700"
              placeholder="Public key"
            />
          </div>
          <button
            onClick={handleVerifySignature}
            disabled={loading || !message || !signature || !pubkey}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-bold shadow"
          >
            {loading ? "Verifying..." : "Verify"}
          </button>
        </section>
      )
    },
    {
      key: "balance",
      icon: "💰",
      label: "Check Balance",
      render: () => (
        <section className="space-y-4">
          <h2 className="text-xl font-bold text-blue-400">💰 Check Balance/Assets</h2>
          <div>
            <label className="block text-gray-300 mb-2">Wallet Address</label>
            <input
              type="text"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              className="w-full p-2 rounded bg-gray-800 text-gray-100 border border-gray-700"
              placeholder="addr1... or stake1..."
            />
          </div>
          <button
            onClick={handleGetBalance}
            disabled={loading || !address}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-bold shadow"
          >
            {loading ? "Fetching..." : "Check Balance"}
          </button>
        </section>
      )
    },
    {
      key: "export",
      icon: "💾",
      label: "Export Wallet",
      render: () => (
        <section className="space-y-4">
          <h2 className="text-xl font-bold text-blue-400">💾 Export Wallet</h2>
          <p className="text-gray-300 mb-4">Export your wallet for backup or import to another device.</p>
          <button
            onClick={handleExportWallet}
            disabled={loading}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white px-6 py-3 rounded font-bold shadow"
          >
            {loading ? "Exporting..." : "Export Wallet"}
          </button>
        </section>
      )
    },
    {
      key: "cleanup",
      icon: "🗑",
      label: "Clean All Keys",
      render: () => (
        <section className="space-y-4">
          <h2 className="text-xl font-bold text-red-400">🗑 Clean All Keys</h2>
          <div className="bg-red-900 border-l-4 border-red-600 p-4 rounded mb-4">
            <p className="font-bold text-red-300">⚠️ Warning: This will permanently delete all generated wallets and keys.</p>
            <p className="text-red-200">This action cannot be undone!</p>
          </div>
          <button
            onClick={handleCleanupKeys}
            disabled={loading}
            className="bg-red-700 hover:bg-red-800 disabled:bg-gray-600 text-white px-6 py-3 rounded font-bold shadow"
          >
            {loading ? "Cleaning..." : "Clean All Keys"}
          </button>
        </section>
      )
    }
  ];

  const activePanelRender = tools.find((t) => t.key === activeTool)?.render;

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 to-blue-900 flex flex-col">
      {/* Header */}
      <header className="flex items-center justify-between px-8 py-4 bg-gray-800 shadow">
        <button className="text-white bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded transition">← Back</button>
        <h1 className="text-2xl font-bold text-blue-300 tracking-wide">👤 End-User Tools</h1>
        <div className="text-sm">
          {pythonReady ? (
            <span className="text-green-400">✓ Backend Ready</span>
          ) : (
            <span className="text-yellow-400">⏳ Connecting...</span>
          )}
        </div>
      </header>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar */}
        <aside className="w-64 bg-gray-800 border-r border-gray-700 flex-shrink-0 p-6">
          <nav className="space-y-2">
            {tools.map((tool) => (
              <button
                key={tool.key}
                className={`w-full flex items-center gap-2 px-4 py-3 rounded-lg font-semibold shadow transition ${
                  activeTool === tool.key
                    ? tool.key === "cleanup"
                      ? "bg-red-700 text-white"
                      : "bg-blue-700 text-white"
                    : "hover:bg-blue-600 text-white"
                }`}
                onClick={() => {
                  setActiveTool(tool.key);
                  setOutput("");
                }}
              >
                <span>{tool.icon}</span> <span>{tool.label}</span>
              </button>
            ))}
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-y-auto p-10 bg-gray-900">
          {activePanelRender && activePanelRender()}
          {error && (
            <div className="mt-4 p-3 bg-red-900 border border-red-600 rounded text-red-200">
              {error}
            </div>
          )}
        </main>

        {/* Output Panel */}
        <aside className="w-96 bg-gray-800 border-l border-gray-700 p-6 overflow-y-auto">
          <h3 className="text-lg font-bold text-blue-300 mb-4">Output</h3>
          <pre className="text-xs text-gray-200 whitespace-pre-wrap break-words">{output}</pre>
        </aside>
      </div>
    </div>
  );
}
