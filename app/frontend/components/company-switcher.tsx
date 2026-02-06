import { router } from "@inertiajs/react"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Building2, Check } from "lucide-react"

interface Company {
  id: number
  name: string
  role: string
}

interface Props {
  companies: Company[]
  currentCompanyId?: number
  className?: string
}

export function CompanySwitcher({ companies, currentCompanyId, className }: Props) {
  const handleCompanyChange = (companyId: string) => {
    router.patch('/company_switch', { company_id: companyId })
  }

  const currentCompany = companies.find(c => c.id === currentCompanyId)

  if (companies.length === 0) {
    return null
  }

  if (companies.length === 1) {
    return (
      <div className={className}>
        <div className="flex items-center gap-2 px-3 py-2 text-sm">
          <Building2 className="h-4 w-4 text-muted-foreground" />
          <span className="font-medium">{companies[0].name}</span>
        </div>
      </div>
    )
  }

  return (
    <Select value={currentCompanyId?.toString()} onValueChange={handleCompanyChange}>
      <SelectTrigger className={className}>
        <div className="flex items-center gap-2">
          <Building2 className="h-4 w-4 text-muted-foreground" />
          <SelectValue placeholder="Select company">
            {currentCompany?.name}
          </SelectValue>
        </div>
      </SelectTrigger>
      <SelectContent>
        {companies.map((company) => (
          <SelectItem key={company.id} value={company.id.toString()}>
            <div className="flex items-center justify-between w-full">
              <div className="flex items-center gap-2">
                <span>{company.name}</span>
                {company.role === 'administrator' && (
                  <span className="text-xs text-muted-foreground">(Admin)</span>
                )}
              </div>
              {company.id === currentCompanyId && (
                <Check className="h-4 w-4 ml-2" />
              )}
            </div>
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}