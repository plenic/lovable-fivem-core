import { motion } from 'framer-motion';
import { InventoryItem } from '@/types/inventory';
import { cn } from '@/lib/utils';
import { X } from 'lucide-react';

interface ItemTooltipProps {
  item: InventoryItem;
  position?: { x: number; y: number };
  onClose?: () => void;
  showActions?: boolean;
  onUse?: () => void;
  onDrop?: () => void;
  onGive?: () => void;
}

const rarityLabels = {
  common: 'Gewöhnlich',
  uncommon: 'Ungewöhnlich',
  rare: 'Selten',
  epic: 'Episch',
  legendary: 'Legendär',
};

const rarityColors = {
  common: 'text-rarity-common',
  uncommon: 'text-rarity-uncommon',
  rare: 'text-rarity-rare',
  epic: 'text-rarity-epic',
  legendary: 'text-rarity-legendary',
};

const categoryLabels: Record<string, string> = {
  weapon: 'Waffe',
  ammo: 'Munition',
  food: 'Essen',
  drink: 'Getränk',
  medical: 'Medizin',
  clothing: 'Kleidung',
  tool: 'Werkzeug',
  material: 'Material',
  key: 'Schlüssel',
  money: 'Geld',
  drug: 'Drogen',
  misc: 'Sonstiges',
};

export const ItemTooltip = ({ 
  item, 
  onClose, 
  showActions = true,
  onUse,
  onDrop,
  onGive,
}: ItemTooltipProps) => {
  return (
    <motion.div
      className="glass-panel rounded-xl p-4 w-72 z-50"
      initial={{ opacity: 0, scale: 0.9, y: 10 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9, y: 10 }}
      transition={{ duration: 0.15 }}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className={cn(
            'w-12 h-12 rounded-lg flex items-center justify-center',
            'bg-gradient-to-br from-secondary to-muted border border-border',
            item.rarity === 'legendary' && 'border-rarity-legendary',
            item.rarity === 'epic' && 'border-rarity-epic',
            item.rarity === 'rare' && 'border-rarity-rare',
          )}>
            <span className="text-2xl">{item.icon}</span>
          </div>
          <div>
            <h3 className="font-display font-bold text-sm text-foreground">{item.name}</h3>
            <p className={cn('text-xs font-medium', rarityColors[item.rarity])}>
              {rarityLabels[item.rarity]}
            </p>
          </div>
        </div>
        {onClose && (
          <button 
            onClick={onClose}
            className="text-muted-foreground hover:text-foreground transition-colors"
          >
            <X size={16} />
          </button>
        )}
      </div>

      {/* Frost Line Divider */}
      <div className="frost-line my-3" />

      {/* Description */}
      <p className="text-sm text-muted-foreground mb-3 leading-relaxed">
        {item.description}
      </p>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-2 text-xs mb-3">
        <div className="flex justify-between bg-muted/30 rounded px-2 py-1.5">
          <span className="text-muted-foreground">Kategorie</span>
          <span className="text-foreground font-medium">{categoryLabels[item.category]}</span>
        </div>
        <div className="flex justify-between bg-muted/30 rounded px-2 py-1.5">
          <span className="text-muted-foreground">Gewicht</span>
          <span className="text-foreground font-medium">{item.weight.toFixed(1)} kg</span>
        </div>
        <div className="flex justify-between bg-muted/30 rounded px-2 py-1.5">
          <span className="text-muted-foreground">Anzahl</span>
          <span className="text-foreground font-medium">{item.quantity}/{item.maxStack}</span>
        </div>
        {item.durability !== undefined && (
          <div className="flex justify-between bg-muted/30 rounded px-2 py-1.5">
            <span className="text-muted-foreground">Zustand</span>
            <span className={cn(
              'font-medium',
              item.durability > 50 ? 'text-success' :
              item.durability > 25 ? 'text-warning' : 'text-destructive'
            )}>
              {item.durability}%
            </span>
          </div>
        )}
      </div>

      {/* Actions */}
      {showActions && (
        <>
          <div className="frost-line my-3" />
          <div className="flex gap-2">
            {item.usable && (
              <button
                onClick={onUse}
                className="flex-1 bg-primary hover:bg-primary/80 text-primary-foreground font-display font-bold text-xs py-2 rounded-lg transition-colors"
              >
                BENUTZEN
              </button>
            )}
            <button
              onClick={onGive}
              className="flex-1 bg-secondary hover:bg-secondary/80 text-secondary-foreground font-display font-bold text-xs py-2 rounded-lg transition-colors"
            >
              GEBEN
            </button>
            <button
              onClick={onDrop}
              className="flex-1 bg-destructive/20 hover:bg-destructive/40 text-destructive font-display font-bold text-xs py-2 rounded-lg transition-colors"
            >
              ABLEGEN
            </button>
          </div>
        </>
      )}
    </motion.div>
  );
};
