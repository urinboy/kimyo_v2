import { Fragment } from 'react';
import { formatChemicalFormulaToParts, chemicalFormulaA11yLabel } from '@/lib/chemicalFormula';

type ChemicalFormulaTextProps = {
  formula: string;
  className?: string;
  'aria-label'?: string;
};

/**
 * Admin kartalar / jadval — kimyoviy formulada raqamlarni past indeks sifatida.
 */
export function ChemicalFormulaText({ formula, className, 'aria-label': ariaLabel }: ChemicalFormulaTextProps) {
  const parts = formatChemicalFormulaToParts(formula);
  const a11y = ariaLabel ?? chemicalFormulaA11yLabel(formula);
  if (parts.length === 0) return null;

  return (
    <span className={className} aria-label={a11y}>
      {parts.map((p, idx) => (
        <Fragment key={`${idx}-${typeof p === 'string' ? p : p.sub}`}>
          {typeof p === 'string' ? p : <sub className="text-[0.72em] font-semibold leading-none">{p.sub}</sub>}
        </Fragment>
      ))}
    </span>
  );
}
