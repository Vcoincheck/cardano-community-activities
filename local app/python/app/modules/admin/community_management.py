"""
COMMUNITY-ADMIN: Community & Event Management (Python)
- Create and manage communities and events
- In-memory store (can be replaced by DB)
"""
from datetime import datetime
from typing import List, Dict, Optional

# In-memory data stores
communities: List[Dict] = []
events: List[Dict] = []

def new_community_dialog() -> Optional[Dict]:
    """Simulate dialog to create a new community (replace with GUI as needed)"""
    community_id = input("Community ID: ").strip()
    name = input("Community Name: ").strip()
    description = input("Description: ").strip()
    if not community_id or not name:
        print("✗ Community ID and Name are required")
        return None
    return {
        "communityId": community_id,
        "name": name,
        "description": description,
        "createdDate": datetime.now().strftime('%Y-%m-%d'),
        "activeMembers": 0,
        "totalEvents": 0,
        "status": "Active"
    }

def new_event_dialog() -> Optional[Dict]:
    """Simulate dialog to create a new event (replace with GUI as needed)"""
    event_id = input("Event ID: ").strip()
    event_name = input("Event Name: ").strip()
    event_date = input("Event Date (YYYY-MM-DD): ").strip() or datetime.now().strftime('%Y-%m-%d')
    location = input("Location: ").strip()
    status = input("Status (Planned/In Progress/Completed/Cancelled): ").strip() or "Planned"
    description = input("Description: ").strip()
    if not event_id or not event_name:
        print("✗ Event ID and Name are required")
        return None
    return {
        "eventId": event_id,
        "eventName": event_name,
        "eventDate": event_date,
        "location": location,
        "status": status,
        "attendees": 0,
        "description": description
    }

def add_community(community_data: Dict) -> bool:
    if not community_data or not community_data.get("communityId") or not community_data.get("name"):
        print("✗ Community ID and Name required")
        return False
    communities.append(community_data)
    print(f"✓ Community '{community_data['name']}' added successfully")
    print(f"  ID: {community_data['communityId']}")
    print(f"  Created: {community_data['createdDate']}")
    return True

def add_event(community_id: str, event_data: Dict) -> bool:
    if not event_data or not event_data.get("eventId") or not event_data.get("eventName"):
        print("✗ Event ID and Name required")
        return False
    event_data["communityId"] = community_id
    events.append(event_data)
    # Update community event count
    for c in communities:
        if c["communityId"] == community_id:
            c["totalEvents"] = c.get("totalEvents", 0) + 1
    print(f"✓ Event '{event_data['eventName']}' added successfully")
    print(f"  ID: {event_data['eventId']}")
    print(f"  Date: {event_data['eventDate']}")
    print(f"  Community: {community_id}")
    return True

def get_all_communities() -> List[Dict]:
    return communities

def get_all_events() -> List[Dict]:
    return events

def get_community_events(community_id: str) -> List[Dict]:
    return [e for e in events if e.get("communityId") == community_id]

if __name__ == "__main__":
    print("Community & Event Management CLI Demo\n==============================")
    while True:
        print("\n1. Add Community\n2. Add Event\n3. List Communities\n4. List Events\n5. List Events by Community\n6. Exit")
        choice = input("Choose: ").strip()
        if choice == '1':
            c = new_community_dialog()
            if c:
                add_community(c)
        elif choice == '2':
            cid = input("Community ID for event: ").strip()
            e = new_event_dialog()
            if e:
                add_event(cid, e)
        elif choice == '3':
            for c in get_all_communities():
                print(c)
        elif choice == '4':
            for e in get_all_events():
                print(e)
        elif choice == '5':
            cid = input("Community ID: ").strip()
            for e in get_community_events(cid):
                print(e)
        elif choice == '6':
            break
        else:
            print("Invalid choice.")
