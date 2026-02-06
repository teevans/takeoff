import { Link } from "@inertiajs/react"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Plus, Users, Building2 } from "lucide-react"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"

interface Company {
  id: number
  name: string
  role: string
  members_count: number
  created_at: string
}

interface Props {
  companies: Company[]
}

export default function CompaniesIndex({ companies }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Companies' }
  ])
  return (
    <div className="container max-w-6xl mx-auto py-8 px-4">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">Companies</h1>
          <p className="text-muted-foreground mt-2">
            Manage your companies and team members
          </p>
        </div>
        <Link href="/companies/new">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Company
          </Button>
        </Link>
      </div>

      {companies.length === 0 ? (
        <Card>
          <CardContent className="text-center py-12">
            <Building2 className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">No companies yet</h3>
            <p className="text-muted-foreground mb-4">
              Create your first company to get started
            </p>
            <Link href="/companies/new">
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Create Company
              </Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {companies.map((company) => (
            <Link key={company.id} href={`/companies/${company.id}`}>
              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader>
                  <div className="flex justify-between items-start">
                    <div>
                      <CardTitle>{company.name}</CardTitle>
                      <CardDescription className="mt-2">
                        <Users className="inline h-4 w-4 mr-1" />
                        {company.members_count} {company.members_count === 1 ? 'member' : 'members'}
                      </CardDescription>
                    </div>
                    <Badge variant={company.role === 'administrator' ? 'default' : 'secondary'}>
                      {company.role}
                    </Badge>
                  </div>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}