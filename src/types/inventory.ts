export type ItemRarity = 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';

export type ItemCategory = 
  | 'weapon' 
  | 'ammo' 
  | 'food' 
  | 'drink' 
  | 'medical' 
  | 'clothing' 
  | 'tool' 
  | 'material' 
  | 'key' 
  | 'money' 
  | 'drug'
  | 'misc';

export type EquipmentSlot = 
  | 'head' 
  | 'face' 
  | 'torso' 
  | 'vest' 
  | 'legs' 
  | 'feet' 
  | 'bag' 
  | 'weapon_primary' 
  | 'weapon_secondary'
  | 'phone'
  | 'keys'
  | 'wallet';

export interface InventoryItem {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: ItemCategory;
  rarity: ItemRarity;
  weight: number;
  quantity: number;
  maxStack: number;
  usable: boolean;
  equipSlot?: EquipmentSlot;
  durability?: number;
  metadata?: Record<string, any>;
}

export interface InventorySlot {
  slotId: number;
  item: InventoryItem | null;
}

export interface EquipmentSlotData {
  slot: EquipmentSlot;
  item: InventoryItem | null;
  label: string;
  icon: string;
}

export interface PlayerInventory {
  slots: InventorySlot[];
  equipment: EquipmentSlotData[];
  maxWeight: number;
  currentWeight: number;
  quickSlots: (InventoryItem | null)[];
}
