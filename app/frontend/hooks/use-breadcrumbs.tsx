import { useEffect } from 'react'
import { useBreadcrumbContext, type Breadcrumb } from '@/contexts/breadcrumb-context'

export function useBreadcrumbs(breadcrumbs: Breadcrumb[]) {
  const { setBreadcrumbs } = useBreadcrumbContext()

  useEffect(() => {
    setBreadcrumbs(breadcrumbs)
    
    // Clear breadcrumbs when component unmounts
    return () => setBreadcrumbs([])
  }, [setBreadcrumbs, JSON.stringify(breadcrumbs)])
}