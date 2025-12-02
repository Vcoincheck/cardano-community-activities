using CommunityAdmin.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CommunityAdmin.Services
{
    /// <summary>
    /// Service for generating and managing signing challenges
    /// </summary>
    public class ChallengeService
    {
        /// <summary>
        /// Generate a new signing challenge for community verification
        /// </summary>
        public async Task<SigningChallenge> GenerateChallengeAsync(
            string communityId = "cardano-community",
            string action = "verify_membership",
            string? customMessage = null)
        {
            return await Task.Run(() =>
            {
                var nonce = Convert.ToBase64String(
                    System.Text.Encoding.UTF8.GetBytes(
                        new Random().Next().ToString() + DateTime.Now.Ticks.ToString()));

                var challenge = new SigningChallenge
                {
                    ChallengeId = Guid.NewGuid().ToString(),
                    CommunityId = communityId,
                    Nonce = nonce,
                    Timestamp = DateTimeOffset.Now.ToUnixTimeSeconds(),
                    Action = action,
                    Message = string.IsNullOrWhiteSpace(customMessage)
                        ? $"I hereby verify my membership and sign this challenge for {communityId}"
                        : customMessage,
                    Expiry = DateTimeOffset.Now.ToUnixTimeSeconds() + 3600 // 1 hour
                };

                return challenge;
            });
        }

        /// <summary>
        /// Validate challenge expiry
        /// </summary>
        public bool ValidateChallenge(SigningChallenge challenge)
        {
            var now = DateTimeOffset.Now.ToUnixTimeSeconds();
            return now <= challenge.Expiry;
        }

        /// <summary>
        /// Check if challenge ID matches
        /// </summary>
        public bool ValidateChallengeId(string expectedId, string actualId)
        {
            return expectedId.Equals(actualId, StringComparison.Ordinal);
        }

        /// <summary>
        /// Export challenge as JSON
        /// </summary>
        public string ExportChallengeAsJson(SigningChallenge challenge)
        {
            try
            {
                return System.Text.Json.JsonSerializer.Serialize(challenge, new System.Text.Json.JsonSerializerOptions
                {
                    WriteIndented = true
                });
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Failed to serialize challenge", ex);
            }
        }
    }
}
