"""
BIP39: Mnemonic & Wordlist Support
"""
import os
from typing import List, Optional


class BIP39:
    """BIP39 Mnemonic support"""
    
    VALID_WORD_COUNTS = [12, 15, 24]
    
    @staticmethod
    def load_wordlist(path: str = None) -> List[str]:
        """
        Load BIP39 wordlist from file
        
        Args:
            path: Path to wordlist file (auto-find if None)
            
        Returns:
            List of words or empty list if not found
        """
        if path is None:
            # Search common locations
            paths = [
                "./wordlist.txt",
                "./end-user-app/wordlist.txt",
                "./local app/powershell/end-user-app/wordlist.txt",
                os.path.join(os.path.dirname(__file__), "../../data/wordlist.txt"),
            ]
            
            for p in paths:
                if os.path.exists(p):
                    path = p
                    break
        
        if not path or not os.path.exists(path):
            print(f"⚠️  Wordlist not found at {path}")
            return []
        
        try:
            with open(path, 'r', encoding='utf-8') as f:
                words = [line.strip().lower() for line in f if line.strip() and line.strip().isalpha()]
            print(f"✓ Loaded {len(words)} words from {path}")
            return words
        except Exception as e:
            print(f"✗ Error loading wordlist: {e}")
            return []
    
    @staticmethod
    def validate_mnemonic(mnemonic: str) -> bool:
        """
        Validate mnemonic format
        
        Args:
            mnemonic: Mnemonic phrase (space-separated words)
            
        Returns:
            True if valid format
        """
        if not mnemonic or not isinstance(mnemonic, str):
            return False
        
        words = mnemonic.strip().lower().split()
        
        if len(words) not in BIP39.VALID_WORD_COUNTS:
            print(f"✗ Invalid word count: {len(words)} (must be 12, 15, or 24)")
            return False
        
        return True
    
    @staticmethod
    def validate_words_exist(mnemonic: str, wordlist: List[str]) -> bool:
        """
        Validate all words exist in wordlist
        
        Args:
            mnemonic: Mnemonic phrase
            wordlist: List of valid words
            
        Returns:
            True if all words valid
        """
        if not wordlist:
            print("⚠️  No wordlist to validate against")
            return False
        
        words = mnemonic.strip().lower().split()
        invalid_words = [w for w in words if w not in wordlist]
        
        if invalid_words:
            print(f"✗ Invalid words: {', '.join(invalid_words)}")
            return False
        
        return True
    
    @staticmethod
    def normalize_mnemonic(mnemonic: str) -> str:
        """
        Normalize mnemonic (lowercase, trim spaces)
        
        Args:
            mnemonic: Mnemonic phrase
            
        Returns:
            Normalized mnemonic
        """
        return " ".join(mnemonic.strip().lower().split())
