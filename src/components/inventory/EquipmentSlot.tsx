import { motion } from 'framer-motion';
import { EquipmentSlotData } from '@/types/inventory';
import { cn } from '@/lib/utils';

interface EquipmentSlotProps {
  data: EquipmentSlotData;
  onClick?: () => void;
  isSelected?: boolean;
}

const slotPositions: Record<string, string> = {
  head: 'col-start-2',
  face: 'col-start-2',
  torso: 'col-start-2',
  vest: 'col-start-3',
  legs: 'col-start-2',
  feet: 'col-start-2',
  bag: 'col-start-1 row-start-2',
  weapon_primary: 'col-start-1 row-start-3',
  weapon_secondary: 'col-start-1 row-start-4',
  phone: 'col-start-3 row-start-2',
  keys: 'col-start-3 row-start-3',
  wallet: 'col-start-3 row-start-4',
};

const rarityBorders: Record<string, string> = {
  common: 'border-rarity-common/60',
  uncommon: 'border-rarity-uncommon/60',
  rare: 'border-rarity-rare/60',
  epic: 'border-rarity-epic/60',
  legendary: 'border-rarity-legendary/60',
};

export const EquipmentSlot = ({ data, onClick, isSelected }: EquipmentSlotProps) => {
  const { item, label, icon } = data;

  return (
    <motion.div
      className={cn(
        'relative w-16 h-16 rounded-lg border-2 cursor-pointer transition-all duration-200',
        'bg-gradient-to-br from-secondary/50 to-muted/30',
        item 
          ? rarityBorders[item.rarity] 
          : 'border-border/50 border-dashed hover:border-primary/50',
        isSelected && 'ring-2 ring-primary border-primary',
        'hover:scale-105'
      )}
      onClick={onClick}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      {/* Glow effect for equipped items */}
      {item && item.rarity !== 'common' && (
        <div 
          className={cn(
            'absolute inset-0 rounded-lg opacity-30 blur-sm',
            item.rarity === 'uncommon' && 'bg-rarity-uncommon',
            item.rarity === 'rare' && 'bg-rarity-rare',
            item.rarity === 'epic' && 'bg-rarity-epic',
            item.rarity === 'legendary' && 'bg-rarity-legendary',
          )}
        />
      )}

      <div className="relative w-full h-full flex items-center justify-center">
        {item ? (
          <>
            <span className="text-2xl select-none">{item.icon}</span>
            {item.durability !== undefined && (
              <div className="absolute bottom-0 left-0 right-0 h-1 bg-black/50 rounded-b-md overflow-hidden">
                <div 
                  className={cn(
                    'h-full',
                    item.durability > 50 ? 'bg-success' :
                    item.durability > 25 ? 'bg-warning' : 'bg-destructive'
                  )}
                  style={{ width: `${item.durability}%` }}
                />
              </div>
            )}
          </>
        ) : (
          <span className="text-xl opacity-30 select-none">{icon}</span>
        )}
      </div>

      {/* Label */}
      <div className="absolute -bottom-5 left-1/2 -translate-x-1/2 whitespace-nowrap">
        <span className="text-[10px] text-muted-foreground font-medium">{label}</span>
      </div>
    </motion.div>
  );
};
