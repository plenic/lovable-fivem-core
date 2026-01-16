import { motion } from 'framer-motion';
import { InventoryItem } from '@/types/inventory';
import { cn } from '@/lib/utils';

interface ItemSlotProps {
  item: InventoryItem | null;
  slotIndex?: number;
  size?: 'sm' | 'md' | 'lg';
  showQuantity?: boolean;
  showDurability?: boolean;
  onClick?: () => void;
  onDragStart?: () => void;
  onDragEnd?: () => void;
  isSelected?: boolean;
  isDropTarget?: boolean;
  className?: string;
}

const sizeClasses = {
  sm: 'w-12 h-12',
  md: 'w-16 h-16',
  lg: 'w-20 h-20',
};

const rarityClasses = {
  common: 'border-rarity-common/50 hover:border-rarity-common',
  uncommon: 'border-rarity-uncommon/50 hover:border-rarity-uncommon',
  rare: 'border-rarity-rare/50 hover:border-rarity-rare',
  epic: 'border-rarity-epic/50 hover:border-rarity-epic',
  legendary: 'border-rarity-legendary/50 hover:border-rarity-legendary rarity-legendary',
};

const rarityGlows = {
  common: '',
  uncommon: 'hover:shadow-[0_0_15px_rgba(34,197,94,0.3)]',
  rare: 'hover:shadow-[0_0_15px_rgba(59,130,246,0.3)]',
  epic: 'hover:shadow-[0_0_15px_rgba(162,0,255,0.4)]',
  legendary: 'shadow-[0_0_20px_rgba(245,158,11,0.4)]',
};

export const ItemSlot = ({
  item,
  slotIndex,
  size = 'md',
  showQuantity = true,
  showDurability = true,
  onClick,
  isSelected,
  isDropTarget,
  className,
}: ItemSlotProps) => {
  return (
    <motion.div
      className={cn(
        'item-slot flex items-center justify-center cursor-pointer relative overflow-hidden group',
        sizeClasses[size],
        item && rarityClasses[item.rarity],
        item && rarityGlows[item.rarity],
        isSelected && 'item-slot-active ring-2 ring-primary',
        isDropTarget && 'border-primary border-dashed bg-primary/10',
        className
      )}
      onClick={onClick}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.2 }}
    >
      {/* Background glow effect */}
      {item && item.rarity !== 'common' && (
        <div 
          className={cn(
            'absolute inset-0 opacity-20 blur-sm',
            item.rarity === 'uncommon' && 'bg-rarity-uncommon',
            item.rarity === 'rare' && 'bg-rarity-rare',
            item.rarity === 'epic' && 'bg-rarity-epic',
            item.rarity === 'legendary' && 'bg-rarity-legendary animate-pulse-glow',
          )}
        />
      )}

      {item ? (
        <>
          {/* Item Icon */}
          <span className="text-2xl relative z-10 select-none">
            {item.icon}
          </span>

          {/* Quantity Badge */}
          {showQuantity && item.quantity > 1 && (
            <div className="absolute bottom-0.5 right-0.5 bg-black/80 text-xs font-bold px-1 rounded text-foreground z-10">
              {item.quantity > 999 ? '999+' : item.quantity}
            </div>
          )}

          {/* Durability Bar */}
          {showDurability && item.durability !== undefined && (
            <div className="absolute bottom-0 left-0 right-0 h-1 bg-black/50">
              <div 
                className={cn(
                  'h-full transition-all',
                  item.durability > 50 ? 'bg-success' :
                  item.durability > 25 ? 'bg-warning' : 'bg-destructive'
                )}
                style={{ width: `${item.durability}%` }}
              />
            </div>
          )}

          {/* Slot Number */}
          {slotIndex !== undefined && slotIndex < 6 && (
            <div className="absolute top-0.5 left-0.5 bg-primary/80 text-[10px] font-bold w-4 h-4 flex items-center justify-center rounded text-primary-foreground z-10">
              {slotIndex + 1}
            </div>
          )}
        </>
      ) : (
        /* Empty Slot Indicator */
        <div className="w-full h-full flex items-center justify-center opacity-20">
          <div className="w-3 h-3 border border-muted-foreground/50 rounded-sm" />
        </div>
      )}
    </motion.div>
  );
};
