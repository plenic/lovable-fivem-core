import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ItemSlot } from './ItemSlot';
import { ItemTooltip } from './ItemTooltip';
import { WeightDisplay } from './WeightDisplay';
import { InventorySlot, InventoryItem, ItemCategory } from '@/types/inventory';
import { cn } from '@/lib/utils';
import { Search, Filter, Grid3X3, LayoutGrid } from 'lucide-react';

interface InventoryGridProps {
  slots: InventorySlot[];
  maxWeight: number;
  currentWeight: number;
  onItemClick?: (item: InventoryItem, slotId: number) => void;
  onItemUse?: (item: InventoryItem) => void;
  onItemDrop?: (item: InventoryItem) => void;
  onItemGive?: (item: InventoryItem) => void;
}

const categoryFilters: { key: ItemCategory | 'all'; label: string; icon: string }[] = [
  { key: 'all', label: 'Alle', icon: '📦' },
  { key: 'weapon', label: 'Waffen', icon: '🔫' },
  { key: 'medical', label: 'Medizin', icon: '🏥' },
  { key: 'food', label: 'Essen', icon: '🍔' },
  { key: 'drink', label: 'Trinken', icon: '💧' },
  { key: 'tool', label: 'Werkzeug', icon: '🔧' },
  { key: 'misc', label: 'Sonstiges', icon: '📎' },
];

export const InventoryGrid = ({
  slots,
  maxWeight,
  currentWeight,
  onItemClick,
  onItemUse,
  onItemDrop,
  onItemGive,
}: InventoryGridProps) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<ItemCategory | 'all'>('all');
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [showTooltip, setShowTooltip] = useState(false);
  const [gridSize, setGridSize] = useState<'small' | 'normal'>('normal');

  const selectedItem = selectedSlot !== null ? slots[selectedSlot]?.item : null;

  const filteredSlots = useMemo(() => {
    return slots.map(slot => {
      if (!slot.item) return slot;
      
      const matchesSearch = slot.item.name.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesCategory = selectedCategory === 'all' || slot.item.category === selectedCategory;

      if (matchesSearch && matchesCategory) {
        return slot;
      }
      return { ...slot, hidden: true };
    });
  }, [slots, searchQuery, selectedCategory]);

  const handleSlotClick = (slotId: number) => {
    const slot = slots[slotId];
    if (slot?.item) {
      setSelectedSlot(slotId);
      setShowTooltip(true);
      onItemClick?.(slot.item, slotId);
    } else {
      setSelectedSlot(null);
      setShowTooltip(false);
    }
  };

  return (
    <motion.div
      className="glass-panel glow-border rounded-2xl p-5 flex flex-col h-full"
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.3 }}
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="font-display font-bold text-lg text-foreground text-glow">
          INVENTAR
        </h2>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setGridSize(gridSize === 'normal' ? 'small' : 'normal')}
            className="p-2 rounded-lg bg-muted/50 hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
          >
            {gridSize === 'normal' ? <Grid3X3 size={16} /> : <LayoutGrid size={16} />}
          </button>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="flex gap-3 mb-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" size={16} />
          <input
            type="text"
            placeholder="Item suchen..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-muted/50 border border-border rounded-lg pl-10 pr-4 py-2 text-sm font-gaming placeholder:text-muted-foreground focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
          />
        </div>
      </div>

      {/* Category Filters */}
      <div className="flex gap-2 mb-4 overflow-x-auto pb-2 scrollbar-gaming">
        {categoryFilters.map((filter) => (
          <button
            key={filter.key}
            onClick={() => setSelectedCategory(filter.key)}
            className={cn(
              'flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-gaming whitespace-nowrap transition-all',
              selectedCategory === filter.key
                ? 'bg-primary text-primary-foreground'
                : 'bg-muted/50 text-muted-foreground hover:bg-muted hover:text-foreground'
            )}
          >
            <span>{filter.icon}</span>
            <span>{filter.label}</span>
          </button>
        ))}
      </div>

      {/* Weight Display */}
      <WeightDisplay 
        current={currentWeight} 
        max={maxWeight} 
        className="mb-4"
      />

      {/* Item Grid */}
      <div className="flex-1 overflow-y-auto scrollbar-gaming pr-1">
        <div className={cn(
          'grid gap-2',
          gridSize === 'normal' ? 'grid-cols-8' : 'grid-cols-10'
        )}>
          {filteredSlots.map((slot, index) => (
            <motion.div
              key={slot.slotId}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ 
                opacity: (slot as any).hidden ? 0.3 : 1, 
                scale: 1,
                filter: (slot as any).hidden ? 'grayscale(1)' : 'none'
              }}
              transition={{ duration: 0.15, delay: index * 0.01 }}
            >
              <ItemSlot
                item={slot.item}
                size={gridSize === 'normal' ? 'md' : 'sm'}
                isSelected={selectedSlot === slot.slotId}
                onClick={() => handleSlotClick(slot.slotId)}
                showQuantity={true}
                showDurability={true}
              />
            </motion.div>
          ))}
        </div>
      </div>

      {/* Item Tooltip Modal */}
      <AnimatePresence>
        {showTooltip && selectedItem && (
          <motion.div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setShowTooltip(false)}
          >
            <div onClick={(e) => e.stopPropagation()}>
              <ItemTooltip
                item={selectedItem}
                onClose={() => setShowTooltip(false)}
                onUse={() => {
                  onItemUse?.(selectedItem);
                  setShowTooltip(false);
                }}
                onDrop={() => {
                  onItemDrop?.(selectedItem);
                  setShowTooltip(false);
                }}
                onGive={() => {
                  onItemGive?.(selectedItem);
                  setShowTooltip(false);
                }}
              />
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
};
