import { motion } from 'framer-motion';
import { ItemSlot } from './ItemSlot';
import { InventoryItem } from '@/types/inventory';
import { cn } from '@/lib/utils';

interface QuickAccessBarProps {
  slots: (InventoryItem | null)[];
  selectedSlot?: number;
  onSlotClick?: (index: number) => void;
}

export const QuickAccessBar = ({ 
  slots, 
  selectedSlot, 
  onSlotClick 
}: QuickAccessBarProps) => {
  return (
    <motion.div
      className="glass-panel glow-border rounded-2xl p-3"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: 0.2 }}
    >
      <div className="flex items-center gap-3">
        {/* Label */}
        <div className="text-xs text-muted-foreground font-display uppercase tracking-wider mr-2">
          Schnellzugriff
        </div>

        {/* Quick Slots */}
        <div className="flex gap-2">
          {slots.map((item, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.2, delay: index * 0.05 }}
            >
              <div className="relative">
                {/* Hotkey Number */}
                <div className={cn(
                  'absolute -top-2 -left-1 z-20 w-5 h-5 rounded flex items-center justify-center',
                  'bg-primary/90 text-primary-foreground text-xs font-display font-bold',
                  'shadow-lg'
                )}>
                  {index + 1}
                </div>
                <ItemSlot
                  item={item}
                  size="md"
                  isSelected={selectedSlot === index}
                  onClick={() => onSlotClick?.(index)}
                  showQuantity={true}
                  showDurability={true}
                />
              </div>
            </motion.div>
          ))}
        </div>

        {/* Keybind Hint */}
        <div className="ml-auto text-[10px] text-muted-foreground/60 font-gaming">
          [1-6] zum schnellen Zugriff
        </div>
      </div>
    </motion.div>
  );
};
