using CommunityAdmin.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace CommunityAdmin.Services
{
    /// <summary>
    /// Service for managing the user registry
    /// </summary>
    public class RegistryService
    {
        private readonly string _registryPath;
        private List<RegistryUser> _userRegistry;

        public RegistryService(string? registryPath = null)
        {
            _registryPath = registryPath ?? Path.Combine(AppContext.BaseDirectory, "data", "user_registry.json");
            _userRegistry = new List<RegistryUser>();
            _ = LoadRegistryAsync();
        }

        /// <summary>
        /// Register a verified user
        /// </summary>
        public async Task<RegistryUser> RegisterVerifiedUserAsync(
            string walletAddress,
            string stakeAddress,
            string challengeId,
            string communityId)
        {
            return await Task.Run(() =>
            {
                var user = new RegistryUser
                {
                    Id = Guid.NewGuid().ToString(),
                    WalletAddress = walletAddress,
                    StakeAddress = stakeAddress,
                    ChallengeId = challengeId,
                    CommunityId = communityId,
                    VerificationDate = DateTime.UtcNow,
                    Status = "verified"
                };

                _userRegistry.Add(user);
                _ = SaveRegistryAsync(); // Fire and forget

                return user;
            });
        }

        /// <summary>
        /// Get registry statistics
        /// </summary>
        public async Task<RegistryStatistics> GetStatisticsAsync()
        {
            return await Task.Run(() =>
            {
                var stats = new RegistryStatistics
                {
                    TotalUsers = _userRegistry.Count,
                    VerifiedUsers = _userRegistry.Count(u => u.Status == "verified"),
                    CommunityCounts = _userRegistry
                        .GroupBy(u => u.CommunityId)
                        .ToDictionary(g => g.Key, g => g.Count()),
                    LastUpdated = DateTime.UtcNow
                };

                return stats;
            });
        }

        /// <summary>
        /// Get all users in registry
        /// </summary>
        public async Task<List<RegistryUser>> GetAllUsersAsync()
        {
            return await Task.Run(() => new List<RegistryUser>(_userRegistry));
        }

        /// <summary>
        /// Find user by wallet address
        /// </summary>
        public async Task<RegistryUser?> FindUserByWalletAsync(string walletAddress)
        {
            return await Task.Run(() =>
                _userRegistry.FirstOrDefault(u => u.WalletAddress == walletAddress));
        }

        /// <summary>
        /// Load registry from file
        /// </summary>
        private async Task LoadRegistryAsync()
        {
            try
            {
                if (File.Exists(_registryPath))
                {
                    var json = await File.ReadAllTextAsync(_registryPath);
                    _userRegistry = JsonSerializer.Deserialize<List<RegistryUser>>(json) ?? new List<RegistryUser>();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading registry: {ex.Message}");
                _userRegistry = new List<RegistryUser>();
            }
        }

        /// <summary>
        /// Save registry to file
        /// </summary>
        private async Task SaveRegistryAsync()
        {
            try
            {
                var directory = Path.GetDirectoryName(_registryPath);
                if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }

                var json = JsonSerializer.Serialize(_userRegistry, new JsonSerializerOptions
                {
                    WriteIndented = true
                });
                await File.WriteAllTextAsync(_registryPath, json);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving registry: {ex.Message}");
            }
        }

        /// <summary>
        /// Export registry as JSON
        /// </summary>
        public async Task<ReportExport> ExportAsJsonAsync(string? outputPath = null)
        {
            outputPath ??= Path.Combine(AppContext.BaseDirectory, "reports");

            return await Task.Run(() =>
            {
                try
                {
                    if (!Directory.Exists(outputPath))
                    {
                        Directory.CreateDirectory(outputPath);
                    }

                    string fileName = $"registry_report_{DateTime.UtcNow:yyyyMMddHHmmss}.json";
                    string filePath = Path.Combine(outputPath, fileName);

                    var json = JsonSerializer.Serialize(_userRegistry, new JsonSerializerOptions
                    {
                        WriteIndented = true
                    });
                    File.WriteAllText(filePath, json);

                    return new ReportExport
                    {
                        Format = "json",
                        OutputPath = outputPath,
                        GeneratedAt = DateTime.UtcNow,
                        RecordsIncluded = _userRegistry.Count,
                        FilePath = filePath
                    };
                }
                catch (Exception ex)
                {
                    throw new InvalidOperationException("Failed to export registry", ex);
                }
            });
        }

        /// <summary>
        /// Export registry as CSV
        /// </summary>
        public async Task<ReportExport> ExportAsCsvAsync(string? outputPath = null)
        {
            outputPath ??= Path.Combine(AppContext.BaseDirectory, "reports");

            return await Task.Run(() =>
            {
                try
                {
                    if (!Directory.Exists(outputPath))
                    {
                        Directory.CreateDirectory(outputPath);
                    }

                    string fileName = $"registry_report_{DateTime.UtcNow:yyyyMMddHHmmss}.csv";
                    string filePath = Path.Combine(outputPath, fileName);

                    using (var writer = new StreamWriter(filePath))
                    {
                        // Write header
                        await writer.WriteLineAsync("Id,WalletAddress,StakeAddress,ChallengeId,CommunityId,VerificationDate,Status");

                        // Write data rows
                        foreach (var user in _userRegistry)
                        {
                            var line = $"{user.Id},{user.WalletAddress},{user.StakeAddress},{user.ChallengeId},{user.CommunityId},{user.VerificationDate:o},{user.Status}";
                            await writer.WriteLineAsync(line);
                        }
                    }

                    return new ReportExport
                    {
                        Format = "csv",
                        OutputPath = outputPath,
                        GeneratedAt = DateTime.UtcNow,
                        RecordsIncluded = _userRegistry.Count,
                        FilePath = filePath
                    };
                }
                catch (Exception ex)
                {
                    throw new InvalidOperationException("Failed to export registry", ex);
                }
            });
        }
    }
}
