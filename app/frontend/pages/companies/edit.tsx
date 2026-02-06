import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Spinner } from "@/components/ui/spinner"
import { Form, Link } from "@inertiajs/react"
import { ArrowLeft } from "lucide-react"
import { useBreadcrumbs } from "@/hooks/use-breadcrumbs"

interface Company {
  id: number
  name: string
}

interface Props {
  company: Company
}

export default function CompaniesEdit({ company }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Companies', href: '/companies' },
    { label: company.name, href: `/companies/${company.id}` },
    { label: 'Edit' }
  ])
  return (
    <div className="container max-w-2xl mx-auto py-8 px-4">
      <Link 
        href={`/companies/${company.id}`} 
        className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground mb-6"
      >
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to company
      </Link>
      
      <Card>
        <CardHeader>
          <CardTitle>Company Settings</CardTitle>
          <CardDescription>
            Update your company details
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form 
            action={`/companies/${company.id}`} 
            method="patch"
          >
            {({ processing, errors }) => (
              <FieldGroup>
                <Field data-invalid={!!errors.name}>
                  <FieldLabel htmlFor="name">Company Name</FieldLabel>
                  <Input
                    id="name"
                    name="name"
                    type="text"
                    defaultValue={company.name}
                    placeholder="Acme Inc."
                    aria-invalid={!!errors.name}
                    required
                  />
                  <FieldDescription>
                    This will be visible to all team members
                  </FieldDescription>
                  {errors.name && (
                    <FieldError>{errors.name}</FieldError>
                  )}
                </Field>
                
                <div className="flex gap-4">
                  <Button type="submit" disabled={processing}>
                    {processing && <Spinner />}
                    Save Changes
                  </Button>
                  <Link href={`/companies/${company.id}`}>
                    <Button type="button" variant="outline">
                      Cancel
                    </Button>
                  </Link>
                </div>
              </FieldGroup>
            )}
          </Form>
        </CardContent>
      </Card>
    </div>
  )
}