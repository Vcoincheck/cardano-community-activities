"""
Community Admin - Community & Event Management
Tạo và quản lý communities và events
"""
from datetime import datetime
from typing import List, Dict, Optional
from app.utils.crypto import Logger


class CommunityManager:
    """Manage communities and events"""
    
    def __init__(self):
        self.communities: List[Dict] = []
        self.events: List[Dict] = []
    
    def add_community(
        self,
        community_id: str,
        name: str,
        description: str
    ) -> bool:
        """Add a new community"""
        Logger.info(f"========== Adding Community ==========", "COMMUNITY")
        
        if not community_id:
            Logger.error("Community ID is required")
            return False
        
        if not name:
            Logger.error("Community Name is required")
            return False
        
        community = {
            'community_id': community_id,
            'name': name,
            'description': description,
            'created_date': datetime.now().strftime('%Y-%m-%d'),
            'active_members': 0,
            'total_events': 0,
            'status': 'Active'
        }
        
        self.communities.append(community)
        
        Logger.success(f"Community '{name}' added successfully")
        print(f"  ID: {community_id}")
        print(f"  Created: {community['created_date']}")
        
        return True
    
    def add_event(
        self,
        community_id: str,
        event_id: str,
        event_name: str,
        event_date: str,
        location: str,
        status: str = "Planned",
        description: str = ""
    ) -> bool:
        """Add a new event to a community"""
        Logger.info(f"========== Adding Event ==========", "EVENT")
        
        if not event_id:
            Logger.error("Event ID is required")
            return False
        
        if not event_name:
            Logger.error("Event Name is required")
            return False
        
        event = {
            'event_id': event_id,
            'community_id': community_id,
            'event_name': event_name,
            'event_date': event_date,
            'location': location,
            'status': status,
            'description': description,
            'attendees': 0
        }
        
        self.events.append(event)
        
        # Update community event count
        for community in self.communities:
            if community['community_id'] == community_id:
                community['total_events'] += 1
                break
        
        Logger.success(f"Event '{event_name}' added successfully")
        print(f"  ID: {event_id}")
        print(f"  Date: {event_date}")
        print(f"  Community: {community_id}")
        
        return True
    
    def get_all_communities(self) -> List[Dict]:
        """Get all communities"""
        return self.communities
    
    def get_all_events(self) -> List[Dict]:
        """Get all events"""
        return self.events
    
    def get_community_events(self, community_id: str) -> List[Dict]:
        """Get events for a specific community"""
        return [e for e in self.events if e['community_id'] == community_id]
    
    def get_community(self, community_id: str) -> Optional[Dict]:
        """Get a specific community"""
        for community in self.communities:
            if community['community_id'] == community_id:
                return community
        return None
