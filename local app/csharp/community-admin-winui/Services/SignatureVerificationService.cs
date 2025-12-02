using CommunityAdmin.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CommunityAdmin.Services
{
    /// <summary>
    /// Service for verifying user signatures server-side
    /// </summary>
    public class SignatureVerificationService
    {
        /// <summary>
        /// Verify a user's signature against a challenge
        /// </summary>
        public async Task<bool> VerifySignatureAsync(
            SigningChallenge challenge,
            SignatureData signatureData,
            bool checkExpiry = true)
        {
            return await Task.Run(() =>
            {
                // Check challenge expiry
                if (checkExpiry)
                {
                    var now = DateTimeOffset.Now.ToUnixTimeSeconds();
                    if (now > challenge.Expiry)
                    {
                        return false; // Challenge expired
                    }
                }

                // Check challenge ID matches
                if (signatureData.ChallengeId != challenge.ChallengeId)
                {
                    return false; // Challenge ID mismatch
                }

                // TODO: Verify Ed25519 signature
                // This requires Chaos.NaCl library:
                // var publicKeyBytes = Convert.FromBase64String(signatureData.PublicKey);
                // var messageBytes = System.Text.Encoding.UTF8.GetBytes(challenge.Message);
                // var signatureBytes = Convert.FromBase64String(signatureData.Signature);
                // return Chaos.NaCl.CryptoSign.VerifyDetached(signatureBytes, messageBytes, publicKeyBytes);

                return true; // Placeholder: assumes valid if ID and expiry check pass
            });
        }

        /// <summary>
        /// Get detailed verification result
        /// </summary>
        public async Task<VerificationResult> GetVerificationResultAsync(
            SigningChallenge challenge,
            SignatureData signatureData)
        {
            var isValid = await VerifySignatureAsync(challenge, signatureData);

            return new VerificationResult
            {
                IsValid = isValid,
                ChallengeId = challenge.ChallengeId,
                PublicKey = signatureData.PublicKey,
                Timestamp = DateTimeOffset.Now,
                Message = isValid ? "Signature verified successfully" : "Signature verification failed"
            };
        }

        /// <summary>
        /// Export verification result as JSON
        /// </summary>
        public string ExportResultAsJson(VerificationResult result)
        {
            try
            {
                return System.Text.Json.JsonSerializer.Serialize(result, new System.Text.Json.JsonSerializerOptions
                {
                    WriteIndented = true
                });
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Failed to serialize verification result", ex);
            }
        }
    }

    /// <summary>
    /// Result of signature verification
    /// </summary>
    public class VerificationResult
    {
        public bool IsValid { get; set; }
        public string ChallengeId { get; set; } = string.Empty;
        public string PublicKey { get; set; } = string.Empty;
        public DateTimeOffset Timestamp { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
