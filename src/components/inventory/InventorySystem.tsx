import { useState, useMemo, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CharacterPanel } from './CharacterPanel';
import { InventoryGrid } from './InventoryGrid';
import { QuickAccessBar } from './QuickAccessBar';
import { InventoryItem, EquipmentSlotData, InventorySlot } from '@/types/inventory';
import { createInitialSlots, createInitialEquipment, createQuickSlots } from '@/data/sampleItems';
import { X } from 'lucide-react';
import forestateLogo from '@/assets/forestate-logo.png';

interface InventorySystemProps {
  isOpen?: boolean;
  onClose?: () => void;
}

export const InventorySystem = ({ isOpen = true, onClose }: InventorySystemProps) => {
  const [slots, setSlots] = useState<InventorySlot[]>(createInitialSlots);
  const [equipment, setEquipment] = useState<EquipmentSlotData[]>(createInitialEquipment);
  const [quickSlots, setQuickSlots] = useState<(InventoryItem | null)[]>(createQuickSlots);
  const [selectedQuickSlot, setSelectedQuickSlot] = useState<number>(0);

  // Calculate current weight
  const currentWeight = useMemo(() => {
    return slots.reduce((total, slot) => {
      if (slot.item) {
        return total + (slot.item.weight * slot.item.quantity);
      }
      return total;
    }, 0);
  }, [slots]);

  const maxWeight = 50;

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Number keys 1-6 for quick slots
      if (e.key >= '1' && e.key <= '6') {
        setSelectedQuickSlot(parseInt(e.key) - 1);
      }
      // ESC to close
      if (e.key === 'Escape') {
        onClose?.();
      }
      // TAB to toggle inventory (prevent default)
      if (e.key === 'Tab') {
        e.preventDefault();
        onClose?.();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const handleSlotsChange = (newSlots: InventorySlot[]) => {
    setSlots(newSlots);
  };

  const handleItemUse = (item: InventoryItem) => {
    console.log('Using item:', item.name);
    // In a real implementation, this would trigger the item's use effect
  };

  const handleItemDrop = (item: InventoryItem) => {
    console.log('Dropping item:', item.name);
    // Remove item from inventory
    setSlots(prev => prev.map(slot => 
      slot.item?.id === item.id ? { ...slot, item: null } : slot
    ));
  };

  const handleItemGive = (item: InventoryItem) => {
    console.log('Giving item:', item.name);
    // In a real implementation, this would open a player selection
  };

  const handleEquipmentClick = (slot: EquipmentSlotData) => {
    console.log('Equipment slot clicked:', slot.slot);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="fixed inset-0 z-50 flex items-center justify-center p-4"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          {/* Backdrop */}
          <motion.div
            className="absolute inset-0 bg-black/70 backdrop-blur-sm"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />

          {/* Main Container */}
          <motion.div
            className="relative w-full max-w-6xl z-10"
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.9, opacity: 0, y: 20 }}
            transition={{ type: 'spring', duration: 0.5 }}
          >
            {/* Header Bar */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <img src={forestateLogo} alt="ForeState" className="w-8 h-8 object-contain" />
                <span className="font-display font-bold text-xl text-foreground text-glow tracking-wider">
                  FORESTATE
                </span>
                <span className="text-muted-foreground font-gaming text-sm">
                  Inventar System
                </span>
              </div>
              <button
                onClick={onClose}
                className="p-2 rounded-lg bg-muted/50 hover:bg-destructive/50 text-muted-foreground hover:text-foreground transition-colors"
              >
                <X size={20} />
              </button>
            </div>

            {/* Main Content */}
            <div className="grid grid-cols-12 gap-4">
              {/* Character Panel - Left */}
              <div className="col-span-4">
                <CharacterPanel
                  equipment={equipment}
                  playerName="Max Mustermann"
                  playerId="12345"
                  onEquipmentClick={handleEquipmentClick}
                />
              </div>

              {/* Inventory Grid - Right */}
              <div className="col-span-8">
                <InventoryGrid
                  slots={slots}
                  maxWeight={maxWeight}
                  currentWeight={currentWeight}
                  onItemUse={handleItemUse}
                  onItemDrop={handleItemDrop}
                  onItemGive={handleItemGive}
                  onSlotsChange={handleSlotsChange}
                />
              </div>
            </div>

            {/* Quick Access Bar */}
            <div className="mt-4">
              <QuickAccessBar
                slots={quickSlots}
                selectedSlot={selectedQuickSlot}
                onSlotClick={setSelectedQuickSlot}
              />
            </div>

            {/* Keybind Hints */}
            <div className="flex justify-center gap-6 mt-4 text-xs text-muted-foreground/60 font-gaming">
              <span>[TAB] Schließen</span>
              <span>[1-6] Schnellzugriff</span>
              <span>[LMB] Item auswählen</span>
              <span>[Drag] Items verschieben</span>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
