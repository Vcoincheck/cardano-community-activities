"""
BIP39 Mnemonic Generator
Generate random BIP39 mnemonics
"""
import random
from typing import List, Optional


class MnemonicGenerator:
    """Generate BIP39 mnemonics"""
    
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
        import os
        
        if path is None:
            paths = [
                "./wordlist.txt",
                "./end-user-app/wordlist.txt",
                "./python/data/wordlist.txt",
                os.path.join(os.path.dirname(__file__), "../../data/wordlist.txt"),
                os.path.join(os.path.dirname(__file__), "../data/wordlist.txt"),
            ]
            
            for p in paths:
                if os.path.exists(p):
                    path = p
                    break
        
        if not path or not os.path.exists(path):
            print(f"⚠️  Wordlist not found")
            return []
        
        try:
            with open(path, 'r', encoding='utf-8') as f:
                words = [line.strip().lower() for line in f if line.strip() and line.strip().isalpha()]
            print(f"✓ Loaded {len(words)} words from wordlist")
            return words
        except Exception as e:
            print(f"✗ Error loading wordlist: {e}")
            return []
    
    @staticmethod
    def generate_mnemonic(word_count: int = 12, wordlist: List[str] = None) -> Optional[str]:
        """
        Generate random BIP39 mnemonic
        
        Args:
            word_count: Number of words (12, 15, or 24)
            wordlist: List of valid BIP39 words
            
        Returns:
            Mnemonic phrase or None
        """
        if word_count not in MnemonicGenerator.VALID_WORD_COUNTS:
            print(f"✗ Invalid word count: {word_count} (must be 12, 15, or 24)")
            return None
        
        if not wordlist:
            wordlist = MnemonicGenerator.load_wordlist()
        
        if not wordlist:
            print("✗ No wordlist available for mnemonic generation")
            return None
        
        try:
            words = random.choices(wordlist, k=word_count)
            mnemonic = " ".join(words)
            print(f"✓ Generated {word_count}-word mnemonic")
            return mnemonic
        except Exception as e:
            print(f"✗ Error generating mnemonic: {e}")
            return None
