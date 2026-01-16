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
  isSelected?: boolean;
  isDropTarget?: boolean;
  isDragging?: boolean;
  isDragOver?: boolean;
  className?: string;
  // Drag and Drop
  draggable?: boolean;
  onDragStart?: (e: React.DragEvent) => void;
  onDragEnd?: (e: React.DragEvent) => void;
  onDragOver?: (e: React.DragEvent) => void;
  onDragLeave?: (e: React.DragEvent) => void;
  onDrop?: (e: React.DragEvent) => void;
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
  isDragging,
  isDragOver,
  className,
  draggable = true,
  onDragStart,
  onDragEnd,
  onDragOver,
  onDragLeave,
  onDrop,
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
        isDragging && 'opacity-50 scale-95 border-primary',
        isDragOver && 'border-primary border-2 bg-primary/20 scale-105 shadow-[0_0_20px_rgba(162,0,255,0.5)]',
        className
      )}
      onClick={onClick}
      draggable={draggable && !!item}
      onDragStart={onDragStart as any}
      onDragEnd={onDragEnd as any}
      onDragOver={onDragOver as any}
      onDragLeave={onDragLeave as any}
      onDrop={onDrop as any}
      whileHover={!isDragging ? { scale: 1.05 } : {}}
      whileTap={!isDragging ? { scale: 0.95 } : {}}
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ 
        opacity: isDragging ? 0.5 : 1, 
        scale: isDragOver ? 1.05 : 1 
      }}
      transition={{ duration: 0.2 }}
    >
      {/* Drop indicator overlay */}
      {isDragOver && (
        <motion.div
          className="absolute inset-0 border-2 border-primary rounded-lg pointer-events-none z-20"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          layoutId="drop-indicator"
        >
          <div className="absolute inset-0 bg-primary/20 animate-pulse" />
        </motion.div>
      )}

      {/* Background glow effect */}
      {item && item.rarity !== 'common' && !isDragging && (
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
          <span className={cn(
            "text-2xl relative z-10 select-none transition-transform",
            isDragging && "scale-75"
          )}>
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
        <div className={cn(
          "w-full h-full flex items-center justify-center transition-opacity",
          isDragOver ? "opacity-50" : "opacity-20"
        )}>
          <div className={cn(
            "w-3 h-3 border rounded-sm transition-colors",
            isDragOver ? "border-primary bg-primary/30" : "border-muted-foreground/50"
          )} />
        </div>
      )}
    </motion.div>
  );
};
