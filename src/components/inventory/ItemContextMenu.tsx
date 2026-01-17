import { motion } from 'framer-motion';
import {
  ContextMenu,
  ContextMenuContent,
  ContextMenuItem,
  ContextMenuSeparator,
  ContextMenuTrigger,
  ContextMenuLabel,
} from '@/components/ui/context-menu';
import { InventoryItem } from '@/types/inventory';
import { 
  Scissors, 
  Eye, 
  ArrowDown, 
  Gift, 
  Hammer, 
  HandHeart,
  Trash2
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface ItemContextMenuProps {
  item: InventoryItem;
  children: React.ReactNode;
  onSplit?: (item: InventoryItem, amount: number) => void;
  onExamine?: (item: InventoryItem) => void;
  onDrop?: (item: InventoryItem) => void;
  onGive?: (item: InventoryItem) => void;
  onUse?: (item: InventoryItem) => void;
  onDestroy?: (item: InventoryItem) => void;
}

const rarityColors = {
  common: 'text-rarity-common',
  uncommon: 'text-rarity-uncommon',
  rare: 'text-rarity-rare',
  epic: 'text-rarity-epic',
  legendary: 'text-rarity-legendary',
};

export const ItemContextMenu = ({
  item,
  children,
  onSplit,
  onExamine,
  onDrop,
  onGive,
  onUse,
  onDestroy,
}: ItemContextMenuProps) => {
  const handleSplit = () => {
    if (item.quantity > 1) {
      // Default: split in half
      const splitAmount = Math.floor(item.quantity / 2);
      onSplit?.(item, splitAmount);
    }
  };

  return (
    <ContextMenu>
      <ContextMenuTrigger asChild>
        {children}
      </ContextMenuTrigger>
      <ContextMenuContent 
        className="w-56 bg-card/95 backdrop-blur-md border-primary/30 font-gaming"
      >
        {/* Item Header */}
        <ContextMenuLabel className="flex items-center gap-2 pb-2">
          <span className="text-xl">{item.icon}</span>
          <div className="flex flex-col">
            <span className={cn('font-bold', rarityColors[item.rarity])}>
              {item.name}
            </span>
            <span className="text-[10px] text-muted-foreground font-normal">
              {item.quantity}x • {(item.weight * item.quantity).toFixed(1)} kg
            </span>
          </div>
        </ContextMenuLabel>
        
        <ContextMenuSeparator className="bg-primary/20" />

        {/* Use Item */}
        {item.usable && (
          <ContextMenuItem 
            onClick={() => onUse?.(item)}
            className="flex items-center gap-2 cursor-pointer hover:bg-primary/20 focus:bg-primary/20"
          >
            <Hammer size={14} className="text-primary" />
            <span>Benutzen</span>
          </ContextMenuItem>
        )}

        {/* Examine */}
        <ContextMenuItem 
          onClick={() => onExamine?.(item)}
          className="flex items-center gap-2 cursor-pointer hover:bg-primary/20 focus:bg-primary/20"
        >
          <Eye size={14} className="text-muted-foreground" />
          <span>Untersuchen</span>
        </ContextMenuItem>

        <ContextMenuSeparator className="bg-primary/20" />

        {/* Split - only if quantity > 1 */}
        {item.quantity > 1 && (
          <ContextMenuItem 
            onClick={handleSplit}
            className="flex items-center gap-2 cursor-pointer hover:bg-primary/20 focus:bg-primary/20"
          >
            <Scissors size={14} className="text-warning" />
            <span>Teilen</span>
            <span className="ml-auto text-xs text-muted-foreground">
              ({Math.floor(item.quantity / 2)}x)
            </span>
          </ContextMenuItem>
        )}

        {/* Give */}
        <ContextMenuItem 
          onClick={() => onGive?.(item)}
          className="flex items-center gap-2 cursor-pointer hover:bg-primary/20 focus:bg-primary/20"
        >
          <HandHeart size={14} className="text-success" />
          <span>Geben</span>
        </ContextMenuItem>

        {/* Drop on ground */}
        <ContextMenuItem 
          onClick={() => onDrop?.(item)}
          className="flex items-center gap-2 cursor-pointer hover:bg-primary/20 focus:bg-primary/20"
        >
          <ArrowDown size={14} className="text-muted-foreground" />
          <span>Auf Boden werfen</span>
        </ContextMenuItem>

        <ContextMenuSeparator className="bg-destructive/30" />

        {/* Destroy */}
        <ContextMenuItem 
          onClick={() => onDestroy?.(item)}
          className="flex items-center gap-2 cursor-pointer text-destructive hover:bg-destructive/20 focus:bg-destructive/20 focus:text-destructive"
        >
          <Trash2 size={14} />
          <span>Zerstören</span>
        </ContextMenuItem>
      </ContextMenuContent>
    </ContextMenu>
  );
};