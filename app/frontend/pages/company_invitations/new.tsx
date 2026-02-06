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
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select"
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

export default function CompanyInvitationsNew({ company }: Props) {
  useBreadcrumbs([
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Companies', href: '/companies' },
    { label: company.name, href: `/companies/${company.id}` },
    { label: 'Invite Member' }
  ])
  return (
    <div className="container max-w-2xl mx-auto py-8 px-4">
      <Link 
        href={`/companies/${company.id}`} 
        className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground mb-6"
      >
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to {company.name}
      </Link>
      
      <Card>
        <CardHeader>
          <CardTitle>Invite Team Member</CardTitle>
          <CardDescription>
            Send an invitation to join {company.name}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form 
            action={`/companies/${company.id}/company_invitations`} 
            method="post"
          >
            {({ processing, errors }) => (
              <FieldGroup>
                <Field data-invalid={!!errors.email}>
                  <FieldLabel htmlFor="email">Email Address</FieldLabel>
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    placeholder="colleague@example.com"
                    aria-invalid={!!errors.email}
                    required
                  />
                  <FieldDescription>
                    We'll send them an invitation to join your company
                  </FieldDescription>
                  {errors.email && (
                    <FieldError>{errors.email}</FieldError>
                  )}
                </Field>

                <Field data-invalid={!!errors.role}>
                  <FieldLabel htmlFor="role">Role</FieldLabel>
                  <Select 
                    name="role" 
                    defaultValue="member"
                  >
                    <SelectTrigger id="role" aria-invalid={!!errors.role}>
                      <SelectValue placeholder="Select a role" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="member">Member</SelectItem>
                      <SelectItem value="administrator">Administrator</SelectItem>
                    </SelectContent>
                  </Select>
                  <FieldDescription>
                    Choose the permissions level for this team member
                  </FieldDescription>
                  {errors.role && (
                    <FieldError>{errors.role}</FieldError>
                  )}
                </Field>
                
                <div className="flex gap-4">
                  <Button type="submit" disabled={processing}>
                    {processing && <Spinner />}
                    Send Invitation
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