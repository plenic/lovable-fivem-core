import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface WeightDisplayProps {
  current: number;
  max: number;
  className?: string;
}

export const WeightDisplay = ({ current, max, className }: WeightDisplayProps) => {
  const percentage = Math.min((current / max) * 100, 100);
  const isOverweight = current >= max * 0.9;
  const isCritical = current >= max;

  return (
    <motion.div 
      className={cn('glass-panel rounded-xl p-3', className)}
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.3 }}
    >
      <div className="flex items-center justify-between mb-2">
        <span className="text-xs font-display text-muted-foreground uppercase tracking-wider">
          Gewicht
        </span>
        <span className={cn(
          'text-sm font-display font-bold',
          isCritical ? 'text-destructive' : 
          isOverweight ? 'text-warning' : 'text-foreground'
        )}>
          {current.toFixed(1)} / {max.toFixed(1)} kg
        </span>
      </div>

      {/* Progress Bar */}
      <div className="h-2 bg-muted/50 rounded-full overflow-hidden">
        <motion.div
          className={cn(
            'h-full rounded-full transition-colors duration-300',
            isCritical ? 'bg-destructive' : 
            isOverweight ? 'bg-warning' : 'bg-primary'
          )}
          initial={{ width: 0 }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
        />
      </div>

      {/* Warning Message */}
      {isOverweight && (
        <motion.p
          className={cn(
            'text-[10px] mt-1.5 font-medium',
            isCritical ? 'text-destructive' : 'text-warning'
          )}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
        >
          {isCritical 
            ? '⚠️ Überladen! Bewegung stark eingeschränkt.' 
            : '⚠️ Fast überladen. Bewegung verlangsamt.'}
        </motion.p>
      )}
    </motion.div>
  );
};
