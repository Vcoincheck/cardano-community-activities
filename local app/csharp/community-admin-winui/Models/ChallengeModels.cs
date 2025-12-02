using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CommunityAdmin.Models
{
    /// <summary>
    /// Represents a cryptographic challenge for community member verification
    /// </summary>
    public class SigningChallenge
    {
        public string ChallengeId { get; set; } = Guid.NewGuid().ToString();
        public string CommunityId { get; set; } = "cardano-community";
        public string Nonce { get; set; } = string.Empty;
        public long Timestamp { get; set; } = DateTimeOffset.Now.ToUnixTimeSeconds();
        public string Action { get; set; } = "verify_membership";
        public string Message { get; set; } = string.Empty;
        public long Expiry { get; set; } = DateTimeOffset.Now.ToUnixTimeSeconds() + 3600; // 1 hour
    }

    /// <summary>
    /// Represents a user's signature data for verification
    /// </summary>
    public class SignatureData
    {
        public string ChallengeId { get; set; } = string.Empty;
        public string PublicKey { get; set; } = string.Empty;
        public string Signature { get; set; } = string.Empty;
        public string WalletAddress { get; set; } = string.Empty;
        public long SignedTimestamp { get; set; } = DateTimeOffset.Now.ToUnixTimeSeconds();
    }

    /// <summary>
    /// Represents a verified community member in the registry
    /// </summary>
    public class RegistryUser
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string WalletAddress { get; set; } = string.Empty;
        public string StakeAddress { get; set; } = string.Empty;
        public string ChallengeId { get; set; } = string.Empty;
        public string CommunityId { get; set; } = string.Empty;
        public DateTime VerificationDate { get; set; } = DateTime.UtcNow;
        public string Status { get; set; } = "verified";
        public Dictionary<string, object>? Metadata { get; set; }
    }

    /// <summary>
    /// Statistics about the registry
    /// </summary>
    public class RegistryStatistics
    {
        public int TotalUsers { get; set; }
        public int VerifiedUsers { get; set; }
        public Dictionary<string, int> CommunityCounts { get; set; } = new();
        public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// On-chain stake information for a user
    /// </summary>
    public class OnChainStakeInfo
    {
        public string StakeAddress { get; set; } = string.Empty;
        public decimal StakeAmount { get; set; }
        public string? DelegatedPoolId { get; set; }
        public decimal RewardsAmount { get; set; }
        public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Report export configuration
    /// </summary>
    public class ReportExport
    {
        public string Format { get; set; } = "json"; // json or csv
        public string OutputPath { get; set; } = string.Empty;
        public DateTime GeneratedAt { get; set; } = DateTime.UtcNow;
        public int RecordsIncluded { get; set; }
        public string? FilePath { get; set; }
    }
}
